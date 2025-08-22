// new_comment_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/presentation/provider/new_comment_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:provider/provider.dart';

class NewCommentPage extends StatelessWidget {
  const NewCommentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final travel = ModalRoute.of(context)!.settings.arguments as Travel;

    return ChangeNotifierProvider(
      create: (_) => NewCommentProvider(travel: travel),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Faça um comentário'),
          centerTitle: true,
        ),
        body: Consumer<NewCommentProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        'Viagem para ${travel.title}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Participante'),
                    const SizedBox(height: 8),
                    _buildDropdownButton<Traveler>(
                      context,
                      items: travel.travelers
                          .map(
                            (traveler) => DropdownMenuItem(
                              value: traveler,
                              child: Text(traveler.name),
                            ),
                          )
                          .toList(),
                      hintText: '...',
                      onChanged: provider.selectTraveler,
                      selectedValue: provider.selectedTraveler,
                    ),
                    const SizedBox(height: 16),
                    const Text('Local da viagem'),
                    const SizedBox(height: 8),
                    _buildDropdownButton<StopPoint>(
                      context,
                      items: travel.stopPoints
                          .map(
                            (stopPoint) => DropdownMenuItem(
                              value: stopPoint,
                              child: Text(stopPoint.locationName),
                            ),
                          )
                          .toList(),
                      hintText: '...',
                      onChanged: provider.selectStopPoint,
                      selectedValue: provider.selectedStopPoint,
                    ),
                    const SizedBox(height: 16),
                    const Text('Comentário'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: provider.contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Fotos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.pickImages,
                      style: AppButtonStyles.primaryButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Selecione',
                            style: TextStyle(color: Colors.blue),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.image, color: Colors.blue),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (provider.selectedImagePaths.isNotEmpty)
                      _buildPhotoPreview(provider.selectedImagePaths, provider),
                    const Divider(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                await provider.saveComment();
                                // Mostrar mensagem de sucesso ou navegar para a tela anterior
                              },
                        style: AppButtonStyles.primaryButtonStyle,
                        child: provider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Salvar',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdownButton<T>(
    BuildContext context, {
    required List<DropdownMenuItem<T>> items,
    required String hintText,
    required Function(T?) onChanged,
    required T? selectedValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          hint: Text(hintText),
          value: selectedValue,
          items: items,
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
            ),
            offset: const Offset(0, 0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: MaterialStateProperty.all(6),
              thumbVisibility: MaterialStateProperty.all(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(
    List<String> imagePaths,
    NewCommentProvider provider,
  ) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          final path = imagePaths[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      provider.removeImage(path);
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
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
