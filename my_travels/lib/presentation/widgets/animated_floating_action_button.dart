import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Este widget é quase idêntico ao anterior, mas sem o FloatingActionButton
class FramelessAnimatedButton extends StatefulWidget {
  final String lottieAsset;
  final VoidCallback onPressed;
  final double size; // Adicionamos um parâmetro para o tamanho

  const FramelessAnimatedButton({
    required this.lottieAsset,
    required this.onPressed,
    this.size = 60.0, // Tamanho padrão de 60x60
    Key? key,
  }) : super(key: key);

  @override
  State<FramelessAnimatedButton> createState() =>
      _FramelessAnimatedButtonState();
}

class _FramelessAnimatedButtonState extends State<FramelessAnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Em vez de um FAB, usamos um GestureDetector para a área de clique
    return GestureDetector(
      onTap: () async {
        if (_controller.isAnimating) return; // Previne múltiplos cliques
        await _controller.forward(from: 0.0);
        widget.onPressed();
      },
      // 2. O filho é apenas o Lottie, sem fundo ou contêiner
      child: Lottie.asset(
        widget.lottieAsset,
        controller: _controller,
        width: widget.size,
        height: widget.size,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
        },
      ),
    );
  }
}
