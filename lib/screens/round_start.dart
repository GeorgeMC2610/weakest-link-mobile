import 'package:flutter/material.dart';
import 'package:weakest_link/classes/player.dart';
import 'package:weakest_link/screens/last_round.dart';
import 'dart:math' as math;

class RoundStart extends StatefulWidget {
  final List<Player> players;
  final int roundNumber;

  const RoundStart({
    super.key,
    required this.players,
    required this.roundNumber,
  });

  @override
  State<RoundStart> createState() => _RoundStartState();
}

class _RoundStartState extends State<RoundStart> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late List<Offset> _sparklePoints;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final random = math.Random();
    _sparklePoints = List.generate(30, (index) {
      return Offset(
        random.nextDouble(),
        random.nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = 5; // 150 - (10 * (widget.roundNumber - 1));
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final formattedTime = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Round ${widget.roundNumber}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Round ${widget.roundNumber}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Remaining Players:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.players.length,
                itemBuilder: (context, index) {
                  final player = widget.players[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: player.isEliminated
                            ? player.color.withOpacity(0.3)
                            : player.color,
                        radius: 12,
                      ),
                      title: Text(
                        player.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: player.isEliminated ? Colors.grey : null,
                          decoration: player.isEliminated
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                      ),
                    ],
                  ),
                  Text(
                    'TIME LIMIT',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                          letterSpacing: 4.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: SparklePainter(
                        animationValue: _pulseController.value,
                        points: _sparklePoints,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      size: const Size(double.infinity, 80),
                    );
                  },
                ),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton.tonal(
                      onPressed: () {
                        Navigator.of(context).push(
                          // MaterialPageRoute(
                          //   builder: (context) => PlayingRound(
                          //     players: widget.players,
                          //     roundNumber: widget.roundNumber,
                          //     totalSeconds: totalSeconds,
                          //   ),
                          // ),

                          MaterialPageRoute(
                            builder: (context) => LastRound(
                              finalists: [widget.players.first, widget.players.last],
                              grandPrize: 1500,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'CLOCK!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SparklePainter extends CustomPainter {
  final double animationValue;
  final List<Offset> points;
  final Color color;

  SparklePainter({
    required this.animationValue,
    required this.points,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent points during a single draw call
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      // Distribute points around the size
      final x = point.dx * size.width;
      final y = point.dy * size.height;

      // Calculate individual sparkle animation
      // Each sparkle has a slightly different phase
      final phase = (animationValue + point.dx) % 1.0;
      final opacity = math.sin(phase * math.pi).abs();
      final scale = 0.5 + opacity * 1.5;

      paint.color = color.withOpacity(opacity * 0.6);
      
      // Draw a small star or dot
      canvas.drawCircle(Offset(x, y), scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) => true;
}
