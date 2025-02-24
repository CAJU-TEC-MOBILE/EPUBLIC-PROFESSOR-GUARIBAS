import 'package:flutter/material.dart';
import '../../models/aula_model.dart';

class CustomCircleSync extends StatefulWidget {
  final Aula aula;

  const CustomCircleSync({super.key, required this.aula});

  @override
  _CustomCircleSyncState createState() => _CustomCircleSyncState();
}

class _CustomCircleSyncState extends State<CustomCircleSync>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.aula.id.isEmpty ?  Container(
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
    ) : AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 15,
            height: 15,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
