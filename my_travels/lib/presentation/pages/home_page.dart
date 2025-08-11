import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:provider/provider.dart';
import 'package:my_travels/presentation/provider/home_provider.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTravel');
        },

        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
      body: SafeArea(
        child: _buildList(provider: provider, travels: travels),
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
