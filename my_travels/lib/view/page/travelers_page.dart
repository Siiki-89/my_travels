import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_travels/view/provider/traveler_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class TravelersPage extends StatelessWidget {
  const TravelersPage({super.key});

  static final TextEditingController _nameController = TextEditingController();
  static final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final whiteUser = false;
    final travelerProvider = context.read<TravelerProvider>();
    final selectedImage = context.watch<TravelerProvider>().selectedImage;

    return Scaffold(
      appBar: AppBar(title: Text('Usuarios'), centerTitle: true),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: whiteUser
            ? ListView()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => _pickImageFromGallery(travelerProvider),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF666666),
                      radius: 28,
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage)
                          : null,
                      child: selectedImage == null
                          ? const Icon(
                              Icons.add_a_photo,
                              size: 28,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  title: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hint: Text('Viajante...'),
                      border: InputBorder.none,
                    ),
                    onChanged: travelerProvider.setName,
                  ),
                  subtitle: TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      hint: Text('Idade'),
                      border: InputBorder.none,
                    ),
                    onChanged: travelerProvider.setAge,
                    keyboardType: TextInputType.number,
                  ),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.delete),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF176FF2),
        onPressed: () async {
          await travelerProvider.addTraveler();
          if (travelerProvider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(travelerProvider.errorMessage!)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Viajante adicionado com sucesso!')),
            );
            _nameController.clear();
            _ageController.clear();
            travelerProvider.resetFields();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future _pickImageFromGallery(TravelerProvider provider) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      provider.setImage(File(pickedFile.path));
    }
  }
}
