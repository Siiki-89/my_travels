import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool? isWhite; // seu parâmetro para controlar o tema

  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isWhite,
  });

  @override
  Widget build(BuildContext context) {
    // 1. LÓGICA DO TEMA
    // Se 'isWhite' for true, significa que o fundo é branco, então usamos cores escuras.
    // Se for falso ou nulo (padrão), o fundo é escuro, então usamos cores claras.
    final bool isForWhiteBackground = isWhite ?? false;

    // Define as cores com base na condição
    final Color textColor = isForWhiteBackground
        ? Colors.black87
        : Colors.white;
    final Color labelColor = isForWhiteBackground
        ? Colors.black54
        : Colors.white70;
    final Color borderColor = isForWhiteBackground
        ? Colors.grey.shade400
        : Colors.white54;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      // 2. APLICA A COR DO TEXTO DINAMICAMENTE
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: labelText,
        // 3. APLICA A COR DA LABEL DINAMICAMENTE
        labelStyle: TextStyle(color: labelColor),

        // Define uma borda padrão para consistência
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: borderColor),
        ),
        // Borda quando o campo está habilitado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: borderColor),
        ),
        // Borda quando o campo está focado (usa a cor primária do tema)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        // Estilos de erro permanecem os mesmos
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
