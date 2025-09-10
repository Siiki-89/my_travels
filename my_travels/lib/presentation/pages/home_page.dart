import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/widgets/animated_floating_action_button.dart';
import 'package:my_travels/presentation/widgets/build_empty_state.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: AnimatedLottieButton(
        onTapAction: () async {
          // Ação específica desta página: navegar para a rota '/addTravel'.
          await Navigator.pushNamed(context, '/addTravel');
        },
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.allTravels.isEmpty
            ? buildEmptyState(
                context,
                'assets/images/lottie/general/loading.json',
                loc.noTravelsTitle,
                loc.noTravelsSubtitle,
                loc.travelManagementHint,
              )
            : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, provider, loc),

                  // --- SEÇÃO DE VIAGENS EM ANDAMENTO ---
                  _buildSectionHeader(loc.ongoingTravels, context),
                  _buildTravelList(
                    provider.ongoingTravels,
                    loc.noOngoingTravels,
                  ),

                  // --- SEÇÃO DE VIAGENS CONCLUÍDAS ---
                  _buildSectionHeader(loc.completedTravels, context),
                  _buildTravelList(
                    provider.completedTravels,
                    loc.noCompletedTravels,
                  ),

                  // Espaçamento no final da lista
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
      ),
    );
  }

  // Helper para construir o cabeçalho de cada seção
  Widget _buildSectionHeader(String title, BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(),
        ),
      ),
    );
  }

  // Helper para construir a lista de viagens ou o estado de vazio da seção
  Widget _buildTravelList(List<Travel> travels, String emptyMessage) {
    if (travels.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Center(
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final travel = travels[index];
        return _TravelCard(travel: travel);
      }, childCount: travels.length),
    );
  }

  // Código original da SliverAppBar (movido para um método para organização)
  Widget _buildSliverAppBar(
    BuildContext context,
    HomeProvider provider,
    AppLocalizations loc,
  ) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      title: Text(
        loc.appName,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
        ),
      ),
      expandedHeight: 260, // Reduzi um pouco a altura para melhor visualização
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56.0), // Ajustei a altura
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          child: _buildSearchBar(provider, loc, context),
        ),
      ),
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/general/image_home.png",
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: -1, // Pequeno ajuste para evitar linhas
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Código original do SearchBar e Botão (sem alterações)
  Widget _buildSearchBar(
    HomeProvider provider,
    AppLocalizations loc,
    BuildContext context,
  ) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        onChanged: provider.search,
        decoration: InputDecoration(
          hintText: loc.homeSearchHint,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// O widget _TravelCard e _TravelerAvatars continuam os mesmos
// (coloque-os no final do seu arquivo home_page.dart)

class _TravelCard extends StatelessWidget {
  final Travel travel;
  const _TravelCard({required this.travel});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final startDestination = travel.stopPoints.isNotEmpty
        ? travel.stopPoints.first.locationName.split(',').first
        : 'Origem';
    final endDestination = travel.stopPoints.length > 1
        ? travel.stopPoints.last.locationName.split(',').first
        : 'Destino';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 220,
        child: Card(
          margin: EdgeInsets.zero, // Ajuste para o novo padding
          elevation: 6,
          shadowColor: Colors.black.withAlpha((0.3 * 255).toInt()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/infoTravel', arguments: travel.id);
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Hero(
                    // Adicionado Hero para animação
                    tag: 'travel_image_${travel.id}',
                    child: Image.file(
                      File(travel.coverImagePath!),
                      fit: BoxFit.cover,
                      frameBuilder: (context, child, frame, wasSyncLoaded) {
                        if (wasSyncLoaded) return child;
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withAlpha((0.7 * 255).toInt()),
                          Colors.black.withAlpha((0.5 * 255).toInt()),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              travel.title,
                              style: textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  const Shadow(
                                    blurRadius: 10,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (travel.travelers.isNotEmpty)
                            _TravelerAvatars(travelers: travel.travelers),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              '$startDestination → $endDestination',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/infoTravel',
                                arguments: travel.id,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              loc.homeButtonExplore,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TravelerAvatars extends StatelessWidget {
  final List<Traveler> travelers;
  const _TravelerAvatars({required this.travelers});

  @override
  Widget build(BuildContext context) {
    const double avatarRadius = 16.0;
    final displayTravelers = travelers.take(4).toList();

    return SizedBox(
      width: (displayTravelers.length * (avatarRadius * 1.5)),
      height: avatarRadius * 2,
      child: Stack(
        children: List.generate(displayTravelers.length, (index) {
          final traveler = displayTravelers[index];
          return Positioned(
            left: index * (avatarRadius * 1.3),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: avatarRadius - 1.5,
                backgroundImage:
                    traveler.photoPath != null && traveler.photoPath!.isNotEmpty
                    ? FileImage(File(traveler.photoPath!))
                    : null,
                child: traveler.photoPath == null || traveler.photoPath!.isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
