import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/domain/errors/failures.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/widgets/animated_floating_action_button.dart';
import 'package:my_travels/presentation/widgets/confirmation_dialog.dart';
import 'package:my_travels/presentation/widgets/build_empty_state.dart';
import 'package:my_travels/presentation/widgets/show_smooth_dialog.dart';
import 'package:my_travels/utils/snackbar_helper.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/custom_text_form_field.dart';

class TravelersPage extends StatelessWidget {
  /// Creates an instance of [TravelersPage].
  const TravelersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final travelerProvider = context.watch<TravelerProvider>();
    final l10n = AppLocalizations.of(context)!;

    // Kicks off the initial data load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      travelerProvider.loadTravelersIfNeeded(l10n);
    });

    return Scaffold(
      appBar: travelerProvider.travelers.isEmpty
          ? null
          : AppBar(title: Text(l10n.users), centerTitle: true),
      body: SafeArea(
        child: travelerProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : travelerProvider.errorMessage != null
            ? Center(child: Text(travelerProvider.errorMessage!))
            : travelerProvider.travelers.isEmpty
            ? buildEmptyState(
                context,
                'assets/images/lottie/general/man_with_map.json',
                l10n.noTravelersTitle,
                l10n.noTravelersSubtitle,
                l10n.travelerManagementHint,
              )
            : const _TravelerListView(),
      ),
      floatingActionButton: AnimatedLottieButton(
        onTapAction: () async {
          context.read<TravelerProvider>().resetFields();
          await showSmoothDialog(
            context: context,
            dialog: CreateAddTravelerDialog(),
          );
        },
      ),
    );
  }
}

/// A private widget that displays the list of travelers.
class _TravelerListView extends StatelessWidget {
  const _TravelerListView();

  @override
  Widget build(BuildContext context) {
    final travelerProvider = context.watch<TravelerProvider>();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 80),
      itemCount: travelerProvider.travelers.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final traveler = travelerProvider.travelers[index];
        return _TravelerListItem(traveler: traveler);
      },
    );
  }
}

/// A private widget to display a single item in the traveler list.
class _TravelerListItem extends StatelessWidget {
  const _TravelerListItem({required this.traveler});

  final Traveler traveler;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final travelerProvider = context.read<TravelerProvider>();

    return ListTile(
      onTap: () {
        travelerProvider.prepareForEdit(traveler);
        showSmoothDialog(context: context, dialog: CreateAddTravelerDialog());
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        radius: 30,
        backgroundImage:
            traveler.photoPath != null && traveler.photoPath!.isNotEmpty
            ? FileImage(File(traveler.photoPath!))
            : null,
        child: traveler.photoPath == null || traveler.photoPath!.isEmpty
            ? const Icon(Icons.person, size: 34)
            : null,
      ),
      title: Text(
        traveler.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${l10n.ageHint}: ${traveler.age ?? ''}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: () async {
          final confirmed = await showSmoothDialog<bool>(
            context: context,
            dialog: ConfirmationDialog(
              title: l10n.confirmDeletionTitle,
              content: l10n.confirmDeletionContent(traveler.name),
              confirmText: l10n.deleteButton,
              cancelText: l10n.cancel,
              onConfirm: () => Navigator.of(context).pop(true),
            ),
          );

          if (confirmed == true && context.mounted) {
            await travelerProvider.deleteTraveler(traveler.id!, l10n);

            if (context.mounted) {
              if (travelerProvider.deleteSuccess) {
                showSuccessSnackBar(context, l10n.travelerDeletedSuccess);
              } else if (travelerProvider.errorMessage != null) {
                showErrorSnackBar(context, travelerProvider.errorMessage!);
              }
            }
          }
        },
      ),
    );
  }
}

/// A dialog for creating or editing a traveler.
class CreateAddTravelerDialog extends StatelessWidget {
  /// Creates an instance of [CreateAddTravelerDialog].
  CreateAddTravelerDialog({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Keys and helpers are created here in a StatelessWidget.

    final picker = ImagePicker();

    final travelerProvider = context.read<TravelerProvider>();
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        height: size.height * 0.45,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Blurred background container
            Positioned.fill(
              top: (size.height * 0.15) / 2,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // Form content
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: (size.height * 0.15) / 2 + 16,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 35),
                      CustomTextFormField(
                        labelText: l10n.travelerNameHint,
                        controller: travelerProvider.nameController,
                        onDarkMode: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.nameRequiredError;
                          }
                          if (value.trim().length < 3) {
                            return l10n.nameMinLengthError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: travelerProvider.ageController,
                        labelText: l10n.ageHint,
                        onDarkMode: true,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterAge;
                          }
                          if (int.tryParse(value) == null) {
                            return l10n.enterValidNumber;
                          }
                          if (int.tryParse(value)! < 0) {
                            return l10n.ageBelowZero;
                          }
                          if (int.tryParse(value)! > 120) {
                            return l10n.ageAboveNormal;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: AppButtonStyles.primaryButtonStyle,
                              child: Text(
                                l10n.cancelButton,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  final provider = context
                                      .read<TravelerProvider>();
                                  try {
                                    // The UI calls the provider method.
                                    await provider.saveTraveler(l10n);

                                    // After the call, the UI reacts to the result.
                                    if (context.mounted &&
                                        provider.saveSuccess) {
                                      final successMessage =
                                          provider.editingId != null
                                          ? l10n.travelerUpdatedSuccess
                                          : l10n.travelerAddedSuccess;
                                      showSuccessSnackBar(
                                        context,
                                        successMessage,
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  } on InvalidTravelerException catch (e) {
                                    if (context.mounted) {
                                      showErrorSnackBar(context, e.message);
                                    }
                                  }
                                }
                              },
                              style: AppButtonStyles.primaryButtonStyle,
                              child: Text(
                                travelerProvider.editingId != null
                                    ? l10n.editButton
                                    : l10n.saveButton,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Circular avatar for photo
            Align(
              alignment: Alignment.topCenter,
              child: InkWell(
                onTap: () async {
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null && context.mounted) {
                    context.read<TravelerProvider>().setImage(
                      File(pickedFile.path),
                    );
                  }
                },
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: size.height * 0.075,
                  backgroundColor: Colors.black,
                  backgroundImage: travelerProvider.selectedImage != null
                      ? FileImage(travelerProvider.selectedImage!)
                      : null,
                  child: Stack(
                    children: [
                      if (travelerProvider.selectedImage == null)
                        Center(
                          child: Icon(
                            Icons.person,
                            size: size.height * 0.075,
                            color: Colors.white,
                          ),
                        ),
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 20.0,
                          child: Icon(
                            Icons.camera_alt,
                            size: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
