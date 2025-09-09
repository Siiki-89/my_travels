import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedLottieButton extends StatefulWidget {
  /// A ação assíncrona que será executada quando o botão for tocado.
  final AsyncCallback onTapAction;

  /// O caminho para o arquivo Lottie.
  final String lottieAsset;

  /// O tamanho do botão (largura e altura).
  final double size;

  const AnimatedLottieButton({
    super.key,
    required this.onTapAction,
    this.lottieAsset = 'assets/images/lottie/buttons/add_button.json',
    this.size = 70.0,
  });

  @override
  State<AnimatedLottieButton> createState() => _AnimatedLottieButtonState();
}

class _AnimatedLottieButtonState extends State<AnimatedLottieButton> {
  // Estado interno para controlar a animação e o duplo clique.
  bool _isAnimating = false;

  Future<void> _handleTap() async {
    // Impede múltiplos toques enquanto a animação está rodando.
    if (_isAnimating) return;

    // Inicia a animação e atualiza a UI.
    setState(() {
      _isAnimating = true;
    });

    // Espera a animação principal do Lottie terminar.
    await Future.delayed(const Duration(milliseconds: 1200));

    // Executa a ação customizada que foi passada para o widget.
    await widget.onTapAction();

    // Uma pequena espera antes de resetar o estado.
    await Future.delayed(const Duration(milliseconds: 200));

    // Garante que o widget ainda está na tela antes de atualizar o estado.
    if (mounted) {
      setState(() {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      splashColor: Colors.transparent,
      child: Lottie.asset(
        widget.lottieAsset,
        key: ValueKey(_isAnimating), // Chave para reiniciar a animação
        animate: _isAnimating,
        width: widget.size,
        height: widget.size,
      ),
    );
  }
}
