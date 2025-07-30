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
            for (int i = 0; i < form.people.length; i++) ...[
              ListTile(
                title: Text(form.people[i].name),
                subtitle: Text(
                  'Idade: ${form.people[i].age}, Local: ${form.people[i].place}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          () => context.read<FormProvider>().expand(index: i),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => context.read<FormProvider>().delete(i),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16),
            TextFormField(
              controller: form.nameController,
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
                child: Text(
                  form.editingIndex != null ? 'Salvar Edição' : 'Concluir',
                ),
              ),
            ],

            const SizedBox(height: 30),
            const Text(
              'Pessoas cadastradas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
