// In lib/presentation/pages/home_page.dart

import 'dart:io';

import 'package:my_travels/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/data/entities/traveler_entity.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:my_travels/presentation/widgets/animated_floating_action_button.dart';
import 'package:my_travels/presentation/widgets/build_empty_state.dart';

/// The main screen of the application, displaying ongoing and completed travels.
class HomePage extends StatelessWidget {
  /// Creates an instance of [HomePage].
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context)!;

    // Kicks off the initial fetch for travels, if it hasn't started yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.fetchTravelsIfNeeded(l10n);
    });

    return Scaffold(
      floatingActionButton: AnimatedLottieButton(
        onTapAction: () async {
          await Navigator.pushNamed(context, '/addTravel');
        },
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.errorMessage != null
            ? Center(child: Text(provider.errorMessage!))
            : provider.allTravels.isEmpty
            ? buildEmptyState(
                context,
                'assets/images/lottie/general/loading.json',
                l10n.noTravelsTitle,
                l10n.noTravelsSubtitle,
                l10n.travelManagementHint,
              )
            : CustomScrollView(
                slivers: [
                  const _SliverAppBar(),

                  if (provider.ongoingTravels.isNotEmpty)
                    _SectionHeader(title: l10n.ongoingTravels),

                  _TravelList(
                    travels: provider.ongoingTravels,
                    emptyMessage: l10n.noOngoingTravels,
                  ),

                  if (provider.completedTravels.isNotEmpty)
                    _SectionHeader(title: l10n.completedTravels),

                  _TravelList(
                    travels: provider.completedTravels,
                    emptyMessage: l10n.noCompletedTravels,
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
      ),
    );
  }
}

// -- PRIVATE WIDGETS (INTERNAL COMPONENTS OF THE PAGE) --

/// The custom SliverAppBar for the home screen, including the search bar.
class _SliverAppBar extends StatelessWidget {
  const _SliverAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SliverAppBar(
      centerTitle: true,

      pinned: true,
      title: Text(
        l10n.appName,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
        ),
      ),
      expandedHeight: 260,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: const _SearchBar(),
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
            bottom: -1,
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
}

/// The search bar widget for the home screen.
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeProvider>();
    final l10n = AppLocalizations.of(context)!;
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        onChanged: provider.search,
        decoration: InputDecoration(
          hintText: l10n.homeSearchHint,
          fillColor: Colors.white12,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
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

/// A sliver widget to display a section header.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}

/// A sliver widget that displays a list of travels or an empty message.
class _TravelList extends StatelessWidget {
  final List<Travel> travels;
  final String emptyMessage;

  const _TravelList({required this.travels, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
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
      delegate: SliverChildBuilderDelegate(
        (context, index) => _TravelCard(travel: travels[index]),
        childCount: travels.length,
      ),
    );
  }
}

/// A card widget to display a single travel summary.
class _TravelCard extends StatelessWidget {
  final Travel travel;
  const _TravelCard({required this.travel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final startDestination = travel.stopPoints.isNotEmpty
        ? travel.stopPoints.first.locationName.split(',').first
        : 'Origin';
    final endDestination = travel.stopPoints.length > 1
        ? travel.stopPoints.last.locationName.split(',').first
        : 'Destination';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 220,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.3),
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
                if (travel.coverImagePath != null)
                  Positioned.fill(
                    child: Hero(
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black87,
                          Colors.black54,
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0.0, 0.5, 1.0],
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
                              l10n.homeButtonExplore,
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

/// A widget that displays a row of overlapping traveler avatars.
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
