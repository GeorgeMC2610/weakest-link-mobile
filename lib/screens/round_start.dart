import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weakest_link/classes/player.dart';
import 'package:weakest_link/classes/question.dart';
import 'package:weakest_link/screens/last_round.dart';
import 'package:weakest_link/screens/playing_round.dart';
import 'package:weakest_link/services/game_manager.dart';

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

class _RoundStartState extends State<RoundStart>
    with SingleTickerProviderStateMixin {
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
        widget.questions,
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
    final totalSeconds =
        70 + (10 * (GameManager().notEliminatedPlayers.length));
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final formattedTime = '$minutes:${seconds.toString().padLeft(2, '0')}';

    final strongestLink = GameManager().strongestLink;
    final remainingPlayers =
        widget.players.where((p) => !p.isEliminated).toList();
    final isDecisiveRound = remainingPlayers.length == 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _isLastRound
              ? translate('round_start.final')
              : translate(
                  'round_start.round',
                  args: {'number': widget.roundNumber},
                ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.5),
            radius: 1.1,
            colors: [
              Color(0xFF071227),
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Ring-style title area
              SizedBox(
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors: [
                            Colors.transparent,
                            Colors.blueAccent,
                            Colors.cyanAccent,
                            Colors.blueAccent,
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.6),
                            blurRadius: 24,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.85),
                        border: Border.all(
                          color: Colors.blueGrey.shade700,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _isLastRound
                              ? translate('round_start.final_round')
                              : (isDecisiveRound
                                  ? translate('round_start.decisive_round')
                                  : translate(
                                      'round_start.round',
                                      args: {'number': widget.roundNumber},
                                    )),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isLastRound
                    ? translate('round_start.finalists')
                    : translate('round_start.remaining_players'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blueGrey.shade100,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.players.length,
                  itemBuilder: (context, index) {
                    final player = widget.players[index];
                    final isEliminated = player.isEliminated;
                    final isStrongest = player.isStrongestLink;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            isEliminated
                                ? Colors.red.withOpacity(0.15)
                                : Colors.blueGrey.withOpacity(0.3),
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                        border: Border.all(
                          color: isStrongest
                              ? Colors.cyanAccent
                              : Colors.blueGrey.shade700,
                          width: isStrongest ? 2.5 : 1,
                        ),
                        boxShadow: isStrongest
                            ? [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.7),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isEliminated
                              ? player.color.withOpacity(0.3)
                              : player.color,
                          radius: 14,
                        ),
                        trailing: isStrongest
                            ? const Icon(Icons.star, color: Colors.cyanAccent)
                            : null,
                        title: Text(
                          player.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color:
                                isEliminated ? Colors.grey : Colors.white,
                            decoration: isEliminated
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
                const SizedBox(height: 8),
                Text(
                  translate(
                    'round_start.pass_or_play',
                    args: {'strongest': strongestLink.name},
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: Colors.blueGrey.shade100,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: Text(translate('round_start.play')),
                      selected: _playFirst == 1,
                      selectedColor: Colors.cyanAccent.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _playFirst == 1
                            ? Colors.cyanAccent
                            : Colors.white70,
                      ),
                      onSelected: (selected) =>
                          setState(() => _playFirst = 1),
                    ),
                    ChoiceChip(
                      label: Text(translate('round_start.pass')),
                      selected: _playFirst == 2,
                      selectedColor: Colors.cyanAccent.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _playFirst == 2
                            ? Colors.cyanAccent
                            : Colors.white70,
                      ),
                      onSelected: (selected) =>
                          setState(() => _playFirst = 2),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              if (!_isLastRound)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.blueGrey.shade700,
                    ),
                    color: Colors.black.withOpacity(0.75),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.cyanAccent,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                      Text(
                        translate('round_start.time_limit'),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: Colors.blueGrey.shade200,
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
                          color: Colors.cyanAccent,
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
                        onPressed:
                            (_isLastRound && _playFirst == null)
                                ? null
                                : () {
                                    if (_isLastRound) {
                                      Navigator.of(context)
                                          .pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => LastRound(
                                            finalists: remainingPlayers
                                              ..sort((a, b) {
                                                if (a.isStrongestLink ==
                                                    b.isStrongestLink) {
                                                  return 0;
                                                }

                                                if (_playFirst == 1) {
                                                  return a.isStrongestLink
                                                      ? -1
                                                      : 1;
                                                } else {
                                                  return a.isStrongestLink
                                                      ? 1
                                                      : -1;
                                                }
                                              }),
                                            grandPrize: GameManager()
                                                .totalBankedPoints,
                                            allQuestions: widget.questions,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PlayingRound(
                                            questions:
                                                GameManager().allQuestions,
                                            players: GameManager().players,
                                            roundNumber: widget.roundNumber,
                                            totalSeconds: totalSeconds,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                        child: Text(
                          _isLastRound
                              ? translate('round_start.start_final')
                              : translate('round_start.clock'),
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

