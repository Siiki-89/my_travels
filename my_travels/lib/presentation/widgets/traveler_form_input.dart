import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:provider/provider.dart';

class TravelerFormInput extends StatelessWidget {
  static final TextEditingController _nameController = TextEditingController();
  static final TextEditingController _ageController = TextEditingController();
  static TextEditingController get nameController => _nameController;
  static TextEditingController get ageController => _ageController;

  const TravelerFormInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelerProvider>(
      builder: (context, travelerProvider, child) {
        if (_nameController.text != travelerProvider.name) {
          _nameController.text = travelerProvider.name;
          _nameController.selection = TextSelection.fromPosition(
            TextPosition(offset: _nameController.text.length),
          );
        }
        if ((_ageController.text != (travelerProvider.age?.toString() ?? ''))) {
          _ageController.text = travelerProvider.age?.toString() ?? '';
          _ageController.selection = TextSelection.fromPosition(
            TextPosition(offset: _ageController.text.length),
          );
        }

        return ListTile(
          leading: GestureDetector(
            onTap: () => _pickImageFromGallery(travelerProvider),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF666666),
              radius: 28,
              backgroundImage: travelerProvider.selectedImage != null
                  ? FileImage(travelerProvider.selectedImage!)
                  : null,
              child: travelerProvider.selectedImage == null
                  ? const Icon(Icons.add_a_photo, size: 28, color: Colors.white)
                  : null,
            ),
          ),
          title: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Viajante...',
              border: InputBorder.none,
            ),
            onChanged: travelerProvider.setName,
          ),
          subtitle: TextField(
            controller: _ageController,
            decoration: const InputDecoration(
              hintText: 'Idade',
              border: InputBorder.none,
            ),
            onChanged: travelerProvider.setAge,
            keyboardType: TextInputType.number,
          ),
          trailing: IconButton(
            onPressed: () {
              _nameController.clear();
              _ageController.clear();
              travelerProvider.resetFields();
              travelerProvider.setEditingId(null);
              travelerProvider.setOptionNow('');
            },
            icon: const Icon(Icons.clear),
          ),
        );
      },
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
