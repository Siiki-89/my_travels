import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/info_travel_provider.dart';
import 'package:provider/provider.dart';

import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/domain/use_cases/comment/save_comment_use_case.dart';
import 'package:my_travels/presentation/provider/new_comment_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/custom_dropdown.dart';
import 'package:my_travels/utils/snackbar_helper.dart';

/// A page for creating a new comment for a specific travel.
class NewCommentPage extends StatelessWidget {
  /// Creates an instance of [NewCommentPage].
  const NewCommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final travelId = ModalRoute.of(context)!.settings.arguments as int;
    final infoProvider = context.read<InfoTravelProvider>();
    final travel = infoProvider.getTravelById(travelId)!;

    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      // Correctly injects the dependency from the provider tree.
      create: (context) => NewCommentProvider(
        travel: travel,
        saveCommentUseCase: context.read<SaveCommentUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.newCommentAppBarTitle),
          centerTitle: true,
        ),
        body: const _NewCommentView(),
      ),
    );
  }
}

/// The main view containing the new comment form.
class _NewCommentView extends StatelessWidget {
  const _NewCommentView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewCommentProvider>();
    final travel = provider.travel;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                l10n.travelFor(travel.title),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.participant,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            CustomDropdown<Traveler>(
              hintText: l10n.selectAuthorHint,
              value: provider.selectedTraveler,
              items: travel.travelers
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: provider.selectTraveler,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.travelLocation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            CustomDropdown<StopPoint>(
              hintText: l10n.linkToLocationHint,
              value: provider.selectedStopPoint,
              items: travel.stopPoints
                  .map(
                    (sp) => DropdownMenuItem(
                      value: sp,
                      child: Text(
                        sp.locationName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: provider.selectStopPoint,
            ),
            const SizedBox(height: 16),
            Text(l10n.comment, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: provider.contentController,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const _ImagePickerArea(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final commentProvider = context
                            .read<NewCommentProvider>();

                        try {
                          await commentProvider.saveComment(l10n);
                          if (context.mounted && commentProvider.saveSuccess) {
                            Navigator.of(context).pop(true);
                          }
                        } on InvalidCommentException catch (e) {
                          if (context.mounted) {
                            showErrorSnackBar(context, e.message);
                          }
                        }
                        // Other errors are handled by the main error state
                        if (context.mounted &&
                            commentProvider.errorMessage != null &&
                            !commentProvider.saveSuccess) {
                          showErrorSnackBar(
                            context,
                            commentProvider.errorMessage!,
                          );
                        }
                      },
                style: AppButtonStyles.primaryButtonStyle,
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        l10n.saveButton,
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerArea extends StatelessWidget {
  /// Creates an instance of [_ImagePickerArea].
  const _ImagePickerArea();

  @override
  Widget build(BuildContext context) {
    // Uses .watch to rebuild when the list of images changes.
    final provider = context.watch<NewCommentProvider>();

    if (provider.selectedImagePaths.isEmpty) {
      // View when no images are selected yet.
      return InkWell(
        onTap: () => provider.pickImages(),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: const Center(
            child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
          ),
        ),
      );
    } else {
      // View when at least one image is selected.
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          // +1 for the "add more" button at the end.
          itemCount: provider.selectedImagePaths.length + 1,
          itemBuilder: (context, index) {
            // Renders the "add more" button at the end of the list.
            if (index == provider.selectedImagePaths.length) {
              return InkWell(
                onTap: () => provider.pickImages(),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 40, color: Colors.grey),
                ),
              );
            }

            // Renders the image preview with a remove button.
            final imagePath = provider.selectedImagePaths[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(imagePath),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => provider.removeImage(imagePath),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }
}
