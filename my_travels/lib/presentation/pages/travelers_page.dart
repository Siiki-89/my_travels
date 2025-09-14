import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/widgets/animated_floating_action_button.dart';
import 'package:my_travels/presentation/widgets/confirmation_dialog.dart';
import 'package:my_travels/presentation/widgets/build_empty_state.dart';
import 'package:my_travels/presentation/widgets/show_smooth_dialog.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/custom_text_form_field.dart';

class TravelersPage extends StatelessWidget {
  const TravelersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final travelerProvider = context.watch<TravelerProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: travelerProvider.travelers.isEmpty
          ? null
          : AppBar(title: Text(appLocalizations.users), centerTitle: true),
      body: SafeArea(
        child: travelerProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : travelerProvider.travelers.isEmpty
            ? buildEmptyState(
                context,
                'assets/images/lottie/general/man_with_map.json',
                appLocalizations.noTravelersTitle,
                appLocalizations.noTravelersSubtitle,
                appLocalizations.travelerManagementHint,
              )
            // A UI agora chama o widget privado e auto-contido.
            : const _TravelerListView(),
      ),
      floatingActionButton: AnimatedLottieButton(
        onTapAction: () async {
          // Ação específica desta página: resetar campos e mostrar dialog.
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

/// Widget privado que exibe a lista de viajantes.
class _TravelerListView extends StatelessWidget {
  const _TravelerListView();

  @override
  Widget build(BuildContext context) {
    final travelerProvider = context.watch<TravelerProvider>();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 80), // Padding para o FAB
      itemCount: travelerProvider.travelers.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final traveler = travelerProvider.travelers[index];
        return _TravelerListItem(traveler: traveler);
      },
    );
  }
}

/// Widget privado para exibir um único item da lista de viajantes.
class _TravelerListItem extends StatelessWidget {
  const _TravelerListItem({required this.traveler});

  final Traveler traveler;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return ListTile(
      onTap: () {
        context.read<TravelerProvider>().prepareForEdit(traveler);
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
      subtitle: Text('${appLocalizations.ageHint}: ${traveler.age}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: () {
          showSmoothDialog(
            context: context,
            dialog: ConfirmationDialog(
              title: appLocalizations.confirmDeletion,
              content:
                  '${appLocalizations.areYouSureYouWantToDelete} ${traveler.name}?',
              confirmText: appLocalizations.delete,
              cancelText: appLocalizations.cancel,
              onConfirm: () async {
                // A ação de deletar é passada aqui
                // O `await` não é mais necessário aqui pois o pop acontece dentro da função
                context.read<TravelerProvider>().deleteTraveler(
                  traveler.id!,
                  context,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CreateAddTravelerDialog extends StatelessWidget {
  CreateAddTravelerDialog({super.key});

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final travelerProvider = context.watch<TravelerProvider>();
    final travelerProviderReader = context.read<TravelerProvider>();
    final size = MediaQuery.of(context).size;
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        height: size.height * 0.45,
        child: Stack(
          alignment: Alignment.center,
          children: [
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
                        labelText: loc.travelerNameHint,
                        controller: travelerProvider.nameController,
                        onDarkMode: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return loc.enterName;
                          }
                          if (value.trim().length < 3) {
                            return 'Deve conter 3 letras ou mais';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: travelerProvider.ageController,
                        labelText: loc.ageHint,
                        keyboardType: TextInputType.number,
                        onDarkMode: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.enterAge;
                          }
                          if (int.tryParse(value) == null) {
                            return loc.enterValidNumber;
                          }
                          if (int.tryParse(value)! < 0) {
                            return loc.ageBelowZero;
                          }
                          if (int.tryParse(value)! > 120) {
                            return loc.ageAboveNormal;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<TravelerProvider>().resetFields();
                                Navigator.of(context).pop();
                              },
                              style: AppButtonStyles.savePersonButtonStyle,
                              child: Text(
                                loc.cancelButton,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  try {
                                    await context
                                        .read<TravelerProvider>()
                                        .saveTraveler();

                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: AppButtonStyles.savePersonButtonStyle,
                              child: Consumer<TravelerProvider>(
                                builder: (context, provider, child) {
                                  return Text(
                                    provider.editingId != null
                                        ? loc.updateHint
                                        : loc.saveButton,
                                    style: const TextStyle(color: Colors.white),
                                  );
                                },
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

            Align(
              alignment: Alignment.topCenter,
              child: InkWell(
                onTap: () async =>
                    await _pickImageFromGallery(travelerProviderReader),
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

  Future<void> _pickImageFromGallery(TravelerProvider provider) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      provider.setImage(File(pickedFile.path));
    } else {
      provider.setImage(null);
    }
  }
}
