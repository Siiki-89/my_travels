import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/traveler.dart';
import 'package:my_travels/view/provider/traveler_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class TravelersPage extends StatelessWidget {
  const TravelersPage({super.key});

  static final TextEditingController _nameController = TextEditingController();
  static final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final travelerProvider = context.watch<TravelerProvider>();
    final selectedImage = travelerProvider.selectedImage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!travelerProvider.isLoading && travelerProvider.travelers.isEmpty) {
        travelerProvider.loadTravelers();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Usuários'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
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
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            Expanded(
              child: travelerProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : travelerProvider.travelers.isEmpty
                  ? const Center(child: Text('Nenhum viajante cadastrado.'))
                  : ListView.builder(
                      itemCount: travelerProvider.travelers.length,
                      itemBuilder: (context, index) {
                        final traveler = travelerProvider.travelers[index];
                        return ListTile(
                          leading: traveler.photoPath != null
                              ? CircleAvatar(
                                  backgroundImage: FileImage(
                                    File(traveler.photoPath!),
                                  ),
                                  radius: 28,
                                )
                              : const CircleAvatar(
                                  backgroundColor: Color(0xFF666666),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                          title: Text(traveler.name),
                          subtitle: Text('Idade: ${traveler.age}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _nameController.text = traveler.name;
                                  _ageController.text =
                                      traveler.age?.toString() ?? '';
                                  travelerProvider.setName(traveler.name);
                                  travelerProvider.setAge(
                                    traveler.age?.toString() ?? '',
                                  );
                                  travelerProvider.setEditingId(traveler.id);
                                  if (traveler.photoPath != null) {
                                    travelerProvider.setImage(
                                      File(traveler.photoPath!),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  travelerProvider.deleteTraveler(traveler.id);
                                  if (travelerProvider.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          travelerProvider.errorMessage!,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Viajante foi apagado!'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF176FF2),
        child: Icon(
          travelerProvider.editingId != null ? Icons.save : Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          if (travelerProvider.editingId != null) {
            final updatedTraveler = Traveler(
              id: travelerProvider.editingId,
              name: travelerProvider.name,
              age: travelerProvider.age,
              photoPath: travelerProvider.selectedImage?.path,
            );
            await travelerProvider.editTraveler(updatedTraveler);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Viajante atualizado com sucesso!')),
            );
          } else {
            await travelerProvider.addTraveler();
            if (travelerProvider.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(travelerProvider.errorMessage!)),
              );
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Viajante adicionado com sucesso!')),
            );
          }

          _nameController.clear();
          _ageController.clear();
          travelerProvider.resetFields();
        },
      ),
    );
  }

  Future<void> _pickImageFromGallery(TravelerProvider provider) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      provider.setImage(File(pickedFile.path));
    }
  }
}
