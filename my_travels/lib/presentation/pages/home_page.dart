import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/widgets/build_empty_state.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0.0,
        title: Text(loc.appName),
      ),
      floatingActionButton: _buildButton(provider, context),

      body: SafeArea(
        child: Stack(
          children: [
            provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.travels.isEmpty
                ? buildEmptyState(
                    context,
                    'assets/images/lottie/general/loading.json',
                    loc.noTravelsTitle,
                    loc.noTravelsSubtitle,
                    loc.travelManagementHint,
                  )
                : _TravelsList(travels: provider.travels),

            if (provider.travels.isNotEmpty)
              Positioned(
                top: 8.0,
                left: 16.0,
                right: 16.0,
                child: _buildSearchBar(provider, loc),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(HomeProvider provider, AppLocalizations loc) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      child: TextField(
        onChanged: provider.search,
        decoration: InputDecoration(
          hintText: loc.homeSearchHint,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  InkWell _buildButton(HomeProvider provider, BuildContext context) {
    return InkWell(
      onTap: () async {
        if (provider.onPressed) return;
        provider.changeOnPressed();
        await Future.delayed(const Duration(milliseconds: 1200));
        Navigator.pushNamed(context, '/addTravel');
        await Future.delayed(const Duration(milliseconds: 200));
        provider.changeOnPressed();
      },
      splashColor: Colors.transparent,
      child: Lottie.asset(
        'assets/images/lottie/buttons/add_button.json',
        key: ValueKey(provider.onPressed),
        animate: provider.onPressed,
        width: 70,
        height: 70,
      ),
    );
  }
}

class _TravelsList extends StatelessWidget {
  const _TravelsList({required this.travels});
  final List<Travel> travels;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 16.0),
      itemCount: travels.length,
      separatorBuilder: (context, index) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final travel = travels[index];
        return _TravelCard(travel: travel);
      },
    );
  }
}

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

    return SizedBox(
      height: 240,
      child: Card(
        margin: const EdgeInsets.only(bottom: 24.0),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            print("Tocou na viagem: ${travel.title}");
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  File(travel.coverImagePath!),
                  fit: BoxFit.cover,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          child: child,
                        );
                      },
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,

                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
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
                          if (travel.travelers.isNotEmpty)
                            _TravelerAvatars(travelers: travel.travelers),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '$startDestination → $endDestination',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/infoTravel',
                                arguments: travel,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                            ),
                            child: Text(loc.homeButtonExplore),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
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
      width: (displayTravelers.length * (avatarRadius * 1.4)),
      height: avatarRadius * 2,
      child: Stack(
        children: List.generate(displayTravelers.length, (index) {
          final traveler = displayTravelers[index];
          return Positioned(
            left: index * (avatarRadius * 1.2),
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
