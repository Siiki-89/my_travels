import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/presentation/provider/new_comment_provider.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/custom_dropdown.dart';
import 'package:provider/provider.dart';

class NewCommentPage extends StatelessWidget {
  const NewCommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final travel = ModalRoute.of(context)!.settings.arguments as Travel;

    return ChangeNotifierProvider(
      // O Provider já cria o UseCase internamente.
      create: (_) => NewCommentProvider(travel: travel),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Faça um comentário'),
          centerTitle: true,
        ),
        body: const _NewCommentView(),
      ),
    );
  }
}

class _NewCommentView extends StatelessWidget {
  const _NewCommentView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewCommentProvider>();
    final travel = provider.travel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                'Viagem para ${travel.title}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Participante',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            CustomDropdown<Traveler>(
              hintText: 'Selecione o autor do comentário',
              value: provider.selectedTraveler,
              items: travel.travelers
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: provider.selectTraveler,
            ),
            const SizedBox(height: 16),
            Text(
              'Local da viagem',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            CustomDropdown<StopPoint>(
              hintText: 'Vincular a um local',
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
            Text('Comentário', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: provider.contentController,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (provider.selectedImagePaths.isNotEmpty)
              _buildPhotoPreview(provider),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: provider.pickImages,
                  style: AppButtonStyles.primaryButtonStyle,
                  icon: const Icon(Icons.image),
                  label: const Text('Selecione Fotos'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        // A UI apenas chama o método...
                        final success = await provider.saveComment(context);
                        // ...e reage ao sucesso.
                        if (success && context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                style: AppButtonStyles.primaryButtonStyle,
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Salvar',
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

  Widget _buildPhotoPreview(NewCommentProvider provider) {
    // Este widget continua o mesmo.
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.selectedImagePaths.length,
        itemBuilder: (context, index) {
          final path = provider.selectedImagePaths[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                    onTap: () => provider.removeImage(path),
                    child: const Icon(Icons.cancel, color: Colors.white),
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
