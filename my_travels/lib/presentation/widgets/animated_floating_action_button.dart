import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FramelessAnimatedButton extends StatefulWidget {
  final String lottieAsset;
  final VoidCallback onPressed;
  final double size;

  const FramelessAnimatedButton({
    required this.lottieAsset,
    required this.onPressed,
    this.size = 60.0,
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
    return GestureDetector(
      onTap: () async {
        if (_controller.isAnimating) return;
        await _controller.forward(from: 0.0);
        widget.onPressed();
      },

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
