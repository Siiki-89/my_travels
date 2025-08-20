import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/custom_text_form_field.dart';
import 'package:provider/provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';

class CreateAddTravelerDialog extends StatefulWidget {
  const CreateAddTravelerDialog({super.key});

  @override
  State<CreateAddTravelerDialog> createState() =>
      _CreateAddTravelerDialogState();
}

class _CreateAddTravelerDialogState extends State<CreateAddTravelerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

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
                    color: Colors.black45,
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return loc.enterName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: travelerProvider.ageController,
                        labelText: loc.ageHint,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return loc.enterAge;
                          }
                          if (int.tryParse(value) == null) {
                            return loc.enterValidNumber;
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

                              style: AppButtonStyles.primaryButtonStyle,
                              child: Text(
                                loc.cancelButton,
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

                                  if (provider.editingId != null) {
                                    await provider.editTraveler(context);
                                  } else {
                                    await provider.addTraveler(context);
                                  }

                                  if (!mounted) return;

                                  Navigator.of(context).pop();
                                }
                              },
                              style: AppButtonStyles.primaryButtonStyle,
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
            // Avatar
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
