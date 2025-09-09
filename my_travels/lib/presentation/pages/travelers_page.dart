import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';
import 'package:my_travels/presentation/widgets/animated_floating_action_button.dart';
import 'package:my_travels/presentation/widgets/confirmation_dialog.dart';
import 'package:my_travels/presentation/widgets/build_empty_state.dart';
import 'package:my_travels/presentation/widgets/show_smooth_dialog.dart';
import 'package:my_travels/presentation/widgets/traveler_create_dialog.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

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
          await showSmoothDialog(context, const CreateAddTravelerDialog());
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
        showSmoothDialog(context, const CreateAddTravelerDialog());
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
            context,
            ConfirmationDialog(
              title: appLocalizations.confirmDeletion,
              content:
                  '${appLocalizations.areYouSureYouWantToDelete} ${traveler.name}?',
              confirmText: appLocalizations.delete,
              cancel: appLocalizations.cancel,
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
