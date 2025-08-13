import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';
import 'package:my_travels/presentation/widgets/custom_text_form_field.dart';
import 'package:provider/provider.dart';
import 'package:my_travels/presentation/provider/traveler_provider.dart';

// 1. Nome da classe corrigido
class CreateAddTravelerDialog extends StatefulWidget {
  const CreateAddTravelerDialog({super.key});

  @override
  State<CreateAddTravelerDialog> createState() =>
      _CreateAddTravelerDialogState();
}

class _CreateAddTravelerDialogState extends State<CreateAddTravelerDialog> {
  // 2. Chave para o formulário
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker(); // Instância única do ImagePicker

  @override
  void initState() {
    super.initState();
    // Se estiver editando, os controllers já foram populados pelo prepareForEdit
    // Não precisamos fazer nada aqui, mas o initState é um bom lugar para lógicas iniciais
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'read' para ações e 'watch' para UI
    final travelerProvider = context.watch<TravelerProvider>();
    final travelerProviderReader = context.read<TravelerProvider>();
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        height: size.height * 0.45, // Aumentei um pouco para caber o scroll
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              top: (size.height * 0.15) / 2,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // 3. Adicionado SingleChildScrollView e Form
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: (size.height * 0.15) / 2 + 16,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 35), // Espaço para o avatar
                      CustomTextFormField(
                        labelText: 'Nome do viajante',
                        controller: travelerProvider.nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: travelerProvider.ageController,
                        labelText: 'Age',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an age.';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // 1. LIMPE O ESTADO ANTES DE SAIR
                                context.read<TravelerProvider>().resetFields();

                                // 2. AGORA FECHE O DIÁLOGO
                                Navigator.of(context).pop();
                              },
                              // ... o resto do seu botão de cancelar
                              style: AppButtonStyles.primaryButtonStyle,
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dentro da Row, substitua o segundo ElevatedButton por este:
                          Expanded(
                            child: ElevatedButton(
                              // 1. TRANSFORME O onPressed EM 'async'
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  final provider = context
                                      .read<TravelerProvider>();

                                  // 2. USE 'await' PARA ESPERAR A OPERAÇÃO TERMINAR
                                  if (provider.editingId != null) {
                                    await provider.editTraveler(context);
                                  } else {
                                    await provider.addTraveler(context);
                                  }

                                  // 3. ADICIONE A VERIFICAÇÃO DE SEGURANÇA 'mounted'
                                  if (!mounted) return;

                                  // 4. AGORA, COM TUDO CONCLUÍDO, FECHE O DIÁLOGO COM SEGURANÇA
                                  Navigator.of(context).pop();
                                }
                              },
                              style: AppButtonStyles.primaryButtonStyle,
                              child: Consumer<TravelerProvider>(
                                builder: (context, provider, child) {
                                  return Text(
                                    provider.editingId != null
                                        ? 'Update'
                                        : 'Save',
                                    style: const TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Avatar
            Align(
              alignment: Alignment.topCenter,
              child: InkWell(
                onTap: () async =>
                    await _pickImageFromGallery(travelerProviderReader),
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: size.height * 0.075,
                  backgroundColor: Colors.black,
                  backgroundImage: travelerProvider.selectedImage != null
                      ? FileImage(travelerProvider.selectedImage!)
                      : null,
                  child: const Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 20.0,
                      child: Icon(
                        Icons.camera_alt,
                        size: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery(TravelerProvider provider) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    // 5. Verificação de 'mounted' não é estritamente necessária aqui porque não estamos usando o context
    // mas o provider.setImage() irá notificar os listeners, então é uma boa prática geral.
    if (pickedFile != null) {
      provider.setImage(File(pickedFile.path));
    } else {
      provider.setImage(null);
    }
  }
}
