import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  Offset _mousePosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _controller2 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _controller3 = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mousePosition = event.position;
        });
      },
      child: Stack(
        children: [
          // Base gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Dark slate
                  Color(0xFF1E293B), // Slate
                  Color(0xFF1E3A8A), // Deep blue
                ],
              ),
            ),
          ),
          
          // Animated orbs
          AnimatedBuilder(
            animation: _controller1,
            builder: (context, child) {
              return CustomPaint(
                painter: OrbPainter(
                  animation1: _controller1.value,
                  animation2: _controller2.value,
                  animation3: _controller3.value,
                  mousePosition: _mousePosition,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Particle layer
          AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  animation: _controller2.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Content
          widget.child,
        ],
      ),
    );
  }
}


class OrbPainter extends CustomPainter {
  final double animation1;
  final double animation2;
  final double animation3;
  final Offset mousePosition;

  OrbPainter({
    required this.animation1,
    required this.animation2,
    required this.animation3,
    required this.mousePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, 100);

    // Orb 1 - Electric Purple
    final orb1X = size.width * 0.2 + math.sin(animation1 * 2 * math.pi) * 100;
    final orb1Y = size.height * 0.3 + math.cos(animation1 * 2 * math.pi) * 80;
    paint.color = Color(0xFF7C3AED).withOpacity(0.3);
    canvas.drawCircle(Offset(orb1X, orb1Y), 150, paint);

    // Orb 2 - Cyan
    final orb2X = size.width * 0.8 + math.cos(animation2 * 2 * math.pi) * 120;
    final orb2Y = size.height * 0.6 + math.sin(animation2 * 2 * math.pi) * 100;
    paint.color = Color(0xFF06B6D4).withOpacity(0.25);
    canvas.drawCircle(Offset(orb2X, orb2Y), 180, paint);

    // Orb 3 - Deep Blue
    final orb3X = size.width * 0.5 + math.sin(animation3 * 2 * math.pi) * 90;
    final orb3Y = size.height * 0.8 + math.cos(animation3 * 2 * math.pi) * 70;
    paint.color = Color(0xFF1E3A8A).withOpacity(0.4);
    canvas.drawCircle(Offset(orb3X, orb3Y), 200, paint);
  }

  @override
  bool shouldRepaint(OrbPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final double animation;

  ParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animation * size.height) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
