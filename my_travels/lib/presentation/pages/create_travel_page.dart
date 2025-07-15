import 'package:flutter/material.dart';
import 'package:my_travels/l10n/app_localizations.dart';

class CreateTravelPage extends StatelessWidget {
  const CreateTravelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.add), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.travelAddTitle),
                    TextFormField(
                      decoration: InputDecoration(hintText: loc.travelAddTitle),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.travelAddStart),
                              TextFormField(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.travelAddFinal),
                              TextFormField(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(loc.travelAddTypeLocomotion),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text(''),
                        items: [],
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(loc.users),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: loc.travelerNameHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.pin_drop, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(loc.travelAddStartintPoint),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(loc.travelAddTypeInterest),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Color(0xFF176FF2),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            label: Text(loc.saveButton),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
