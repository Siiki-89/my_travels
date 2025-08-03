import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:provider/provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';

class CreateAddTrevelerDialog extends StatelessWidget {
  const CreateAddTrevelerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final travelerProvider = context.watch<TravelerProvider>();
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        height: size.height * 0.4,
        child: Stack(
          children: [
            Positioned(
              top: (size.height * 0.2) / 2,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: size.width * 0.8,
                  height: size.height * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: travelerProvider.nameController,
                      decoration: InputDecoration(
                        labelText: 'Traveler Name',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: travelerProvider.ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ),
                                        const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              travelerProvider.addTraveler();
                              Navigator.of(context).pop();
                            },
                            child: Text('Save', style: TextStyle(color: Colors.white)),
                            style: AppButtonStyles.primaryButtonStyle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded( child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel', style: TextStyle(color: Colors.white)),
                          style: AppButtonStyles.primaryButtonStyle,
                        ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: size.height * 0.15,
                width: size.height * 0.15,
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  color: Colors.black,
                ),
                child: InkWell(
                  onTap: () async =>
                      await _pickImageFromGallery(travelerProvider),
                  customBorder: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundImage: travelerProvider.selectedImage != null
                        ? FileImage(travelerProvider.selectedImage!)
                        : null,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 20.0,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      provider.setImage(File(pickedFile.path));
    } else {
      provider.setImage(null);
    }
  }
}
