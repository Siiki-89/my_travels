import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'form_provider.dart';

class AnimatedForm extends StatelessWidget {
  const AnimatedForm({super.key});

  @override
  Widget build(BuildContext context) {
    final form = context.watch<FormProvider>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: form.nameController,
              readOnly: form.submittedName != null,
              decoration: const InputDecoration(labelText: 'Nome'),
              onTap: () {
                if (!form.isExpanded) {
                  context.read<FormProvider>().expand();
                }
              },
            ),
            if (form.isExpanded) ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: form.ageController,
                decoration: const InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: form.placeController,
                decoration: const InputDecoration(
                  labelText: 'Local de nascimento',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<FormProvider>().submit(),
                child: const Text('Concluir'),
              ),
            ],
            if (form.submittedName != null) ...[
              const SizedBox(height: 20),
              Text('Olá, ${form.submittedName!}!'),
            ],
          ],
        ),
      ),
    );
  }
}
