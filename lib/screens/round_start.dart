import 'package:flutter/material.dart';
import 'package:weakest_link/classes/player.dart';
import 'package:weakest_link/classes/question.dart';
import 'package:weakest_link/services/game_manager.dart';
import 'dart:math' as math;

import 'package:weakest_link/screens/playing_round.dart';
import 'package:weakest_link/screens/last_round.dart';

class RoundStart extends StatefulWidget {
  final List<Player> players;
  final List<Question> questions;
  final int roundNumber;

  const RoundStart({
    super.key,
    required this.players,
    required this.questions,
    required this.roundNumber,
  });

  @override
  State<RoundStart> createState() => _RoundStartState();
}

class _RoundStartState extends State<RoundStart> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late List<Offset> _sparklePoints;
  int? _playFirst; // null: not decided, 1: play (start), 2: pass (other starts)

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

    if (widget.roundNumber == 1) {
      GameManager().startGame(
        widget.players,
        widget.questions
      );
    }

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

  bool get _isLastRound => widget.roundNumber == GameManager().totalRounds;

  @override
  Widget build(BuildContext context) {
    // Standard rounds time limit logic
    final totalSeconds = 70 + (10 * (GameManager().notEliminatedPlayers.length));
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final formattedTime = '$minutes:${seconds.toString().padLeft(2, '0')}';

    final strongestLink = GameManager().strongestLink;
    final remainingPlayers = widget.players.where((p) => !p.isEliminated).toList();
    final isDecisiveRound = remainingPlayers.length == 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLastRound ? 'Final' : 'Round ${widget.roundNumber}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _isLastRound ? 'FINAL ROUND' : (isDecisiveRound ? 'DECISIVE ROUND' : 'Round ${widget.roundNumber}'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              _isLastRound ? 'The Finalists:' : 'Remaining Players:',
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
                      trailing: player.isStrongestLink 
                        ? const Icon(Icons.star, color: Colors.amber)
                        : null,
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
            if (_isLastRound && strongestLink != null) ...[
               Text(
                '${strongestLink.name}, as Strongest Link,\ndo you want to play or pass?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    label: const Text('Play'),
                    selected: _playFirst == 1,
                    onSelected: (selected) => setState(() => _playFirst = 1),
                  ),
                  ChoiceChip(
                    label: const Text('Pass'),
                    selected: _playFirst == 2,
                    onSelected: (selected) => setState(() => _playFirst = 2),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 24),
            if (!_isLastRound)
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
                      onPressed: (_isLastRound && _playFirst == null) ? null : () {
                        if (_isLastRound) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LastRound(
                                finalists: remainingPlayers..sort((a, b) {
                                  if (a.isStrongestLink == b.isStrongestLink) return 0;

                                  if (_playFirst == 1) {
                                    return a.isStrongestLink ? -1 : 1;
                                  } else {
                                    return a.isStrongestLink ? 1 : -1;
                                  }
                                }),
                                grandPrize: GameManager().totalBankedPoints,
                                allQuestions: widget.questions,
                              ),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlayingRound(
                                questions: GameManager().allQuestions,
                                players: GameManager().players,
                                roundNumber: widget.roundNumber,
                                totalSeconds: totalSeconds,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        _isLastRound ? 'START FINAL' : 'CLOCK!',
                        style: const TextStyle(
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
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final x = point.dx * size.width;
      final y = point.dy * size.height;

      final phase = (animationValue + point.dx) % 1.0;
      final opacity = math.sin(phase * math.pi).abs();
      final scale = 0.5 + opacity * 1.5;

      paint.color = color.withOpacity(opacity * 0.6);
      
      canvas.drawCircle(Offset(x, y), scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) => true;
}
