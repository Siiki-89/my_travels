import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final int? maxLength;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  /// Adicione este parâmetro. Se `true`, usará cores claras para fundos escuros.
  final bool onDarkMode;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.maxLength,
    this.validator,
    this.keyboardType = TextInputType.text,
    // O padrão é `false`, então você não precisa mudar nada nas outras telas.
    this.onDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Se onDarkMode for true, usa um conjunto de cores claras.
    // Caso contrário, usa as cores do tema padrão do app.
    final colorScheme = onDarkMode
        ? const ColorScheme.dark(
            primary: Colors.white, // Cor do foco
            onSurface: Colors.white, // Cor do texto digitado
            onSurfaceVariant: Colors.white70, // Cor do label/dica
            outline: Colors.white54, // Cor da borda
            error: Color.fromARGB(255, 255, 100, 89), // Cor de erro clara
          )
        : Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
