import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:provider/provider.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final travels = provider.travels;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const Text(
            'Viagens',
            style: TextStyle(color: Colors.white),
          ),
          secondChild: TextField(
            style: TextStyle(color: Colors.white),
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Buscar...',
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
            onChanged: provider.search,
          ),
          crossFadeState: provider.searchVisible
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
        actions: [
          IconButton(
            icon: Icon(provider.searchVisible ? Icons.close : Icons.search),
            onPressed: () {
              if (provider.searchVisible) {
                provider.cancelSearch();
              } else {
                provider.initSearch();
              }
            },
          ),
        ],
      ),

      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [
            _buildList(provider: provider, travels: travels),
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildButton(provider, context),
            ),
          ],
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

class _buildList extends StatelessWidget {
  const _buildList({super.key, required this.provider, required this.travels});

  final HomeProvider provider;
  final List<Travel> travels;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: travels.length,
      itemBuilder: (context, index) {
        final travel = travels[index];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Image.file(
                  File(travel.coverImagePath!),
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      travel.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
