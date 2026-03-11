import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:weakest_link/classes/player.dart';
import 'package:weakest_link/classes/question.dart';
import 'package:weakest_link/screens/voting_phase.dart';
import 'package:weakest_link/services/game_manager.dart';
import 'package:weakest_link/screens/round_start.dart';

class PlayingRound extends StatefulWidget {
  final List<Player> players;
  final List<Question> questions;
  final int roundNumber;
  final int totalSeconds;
  final int? playFirst;

  const PlayingRound({
    super.key,
    required this.players,
    required this.questions,
    required this.roundNumber,
    required this.totalSeconds,
    this.playFirst,
  });

  @override
  State<PlayingRound> createState() => _PlayingRoundState();
}

class _PlayingRoundState extends State<PlayingRound> with TickerProviderStateMixin {
  final List<int> _pointsScale = [0, 20, 50, 100, 200, 300, 450, 600, 800, 1000];
  int _currentChainIndex = 0;
  int _roundBankedPoints = 0;
  int _currentPlayerIndex = 0;
  late List<Player> _activePlayers;

  // Timer logic
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRoundActive = false;
  bool _isStarting = true;
  bool _isTimeOver = false;
  bool _showAnswer = false;
  bool get showAnswer => GameManager().hostMode ? true : _showAnswer;

  // Animation logic for the starting lights
  late AnimationController _startLightsController;

  // Animation for the glowing money ladder
  late AnimationController _ladderPulseController;
  late Animation<double> _ladderPulseAnimation;

  // Question logic
  late Question _currentQuestion;

  @override
  void initState() {
    super.initState();
    _activePlayers = widget.players.where((p) => !p.isEliminated).toList();
    _remainingSeconds = widget.totalSeconds;
    
    // Determine who starts
    if (widget.roundNumber == 1) {
      _activePlayers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _currentPlayerIndex = 0;
    } else {
      final strongest = GameManager().strongestLink;
      if (strongest != null) {
        final index = _activePlayers.indexOf(strongest);
        _currentPlayerIndex = index != -1 ? index : 0;
      }
    }

    _currentQuestion = GameManager().getNextStandardQuestion();

    _startLightsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );

    _ladderPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _ladderPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ladderPulseController,
        curve: Curves.easeInOut,
      ),
    );

    _startLightsController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isStarting = false;
          _startRound();
        });
      }
    });

    _startLightsController.forward();
  }

  void _startRound() {
    setState(() {
      _isRoundActive = true;
      _isTimeOver = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isTimeOver = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _startLightsController.dispose();
    _ladderPulseController.dispose();
    super.dispose();
  }

  void _nextPlayer() {
    setState(() {
      _showAnswer = false;
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _activePlayers.length;
      _currentQuestion = GameManager().getNextStandardQuestion();
    });
  }

  void _handleCorrect() {
    if (!_isRoundActive) return;
    final currentPlayer = _activePlayers[_currentPlayerIndex];
    setState(() {
      currentPlayer.rightAnswers++;
      if (_currentChainIndex < _pointsScale.length - 1) {
        _currentChainIndex++;
      }
      _nextPlayer();
    });
  }

  void _handleWrong() {
    if (!_isRoundActive) return;
    final currentPlayer = _activePlayers[_currentPlayerIndex];
    setState(() {
      currentPlayer.wrongAnswers++;
      _currentChainIndex = 0;
      _nextPlayer();
    });
  }

  void _handleBank() {
    if (!_isRoundActive || _currentChainIndex == 0) return;
    final currentPlayer = _activePlayers[_currentPlayerIndex];
    setState(() {
      final bankedAmount = _pointsScale[_currentChainIndex];
      _roundBankedPoints += bankedAmount;
      currentPlayer.pointsSaved += bankedAmount;
      _currentChainIndex = 0;
    });
  }

  void _handleBurn() {
    if (!_isRoundActive) return;
    setState(() {
      _currentQuestion = GameManager().getNextStandardQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isStarting) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AnimatedBuilder(
            animation: _startLightsController,
            builder: (context, child) {
              return CustomPaint(
                painter: StartingLightsPainter(
                  progress: _startLightsController.value,
                  roundNumber: widget.roundNumber,
                ),
                size: const Size(300, 300),
              );
            },
          ),
        ),
      );
    }

    final currentPlayer = _activePlayers[_currentPlayerIndex];
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeStr = "$minutes:${seconds.toString().padLeft(2, '0')}";

    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AutoSizeText(
                translate('rounds.banked', args: {'points': _roundBankedPoints}),
                maxLines: 1,
                minFontSize: 10,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _remainingSeconds < 10
                      ? [Colors.redAccent, Colors.red]
                      : [Colors.blueAccent, Colors.lightBlueAccent],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _remainingSeconds < 10
                        ? Colors.redAccent.withOpacity(0.8)
                        : Colors.blueAccent.withOpacity(0.8),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                timeStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.2,
            colors: [
              Color(0xFF0A0F24),
              Colors.black,
            ],
          ),
        ),
        child: Row(
          children: [
            // Points Scale Sidebar
            Container(
              width: 110,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF02030A),
                    Color(0xFF050B19),
                  ],
                ),
              ),
              child: AnimatedBuilder(
                animation: _ladderPulseAnimation,
                builder: (context, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_pointsScale.length, (index) {
                      int reverseIndex = _pointsScale.length - 1 - index;
                      if (reverseIndex == 0) return const SizedBox.shrink();
                      
                      bool isTarget = _currentChainIndex == reverseIndex;
                      final baseColor = isTarget
                          ? Colors.cyanAccent
                          : Colors.blueGrey.shade700;
                      final glowStrength = isTarget ? _ladderPulseAnimation.value : 0.0;

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: baseColor.withOpacity(0.7),
                              width: 1.5,
                            ),
                            boxShadow: isTarget
                                ? [
                                    BoxShadow(
                                      color: Colors.cyanAccent
                                          .withOpacity(0.6 * (0.4 + glowStrength)),
                                      blurRadius: 16 + (8 * glowStrength),
                                      spreadRadius: 1.5 + glowStrength,
                                    ),
                                  ]
                                : [],
                            gradient: LinearGradient(
                              colors: isTarget
                                  ? [
                                      Color(0xFF081E3F),
                                      Color(0xFF0D4E89),
                                    ]
                                  : [
                                      Color(0xFF020814),
                                      Color(0xFF02101F),
                                    ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${_pointsScale[reverseIndex]}',
                              style: TextStyle(
                                fontSize: isTarget ? 20 : 16,
                                fontWeight: FontWeight.bold,
                                color: isTarget
                                    ? Colors.cyanAccent
                                    : Colors.blueGrey.shade200,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  children: [
                    // Player Turn Indicator
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: LinearGradient(
                          colors: [
                            currentPlayer.color.withOpacity(0.7),
                            currentPlayer.color.withOpacity(0.15),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: currentPlayer.color.withOpacity(0.7),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                        border: Border.all(
                          color: currentPlayer.color,
                          width: 2.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            translate('rounds.current_player'),
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: 3,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currentPlayer.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: (isLandscape
                                    ? Theme.of(context).textTheme.headlineSmall
                                    : Theme.of(context).textTheme.headlineMedium)
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    
                    // Question & Answer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF020812).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentQuestion.title,
                            textAlign: TextAlign.center,
                            style: (isLandscape
                                    ? Theme.of(context).textTheme.titleLarge
                                    : Theme.of(context).textTheme.headlineSmall)
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          !showAnswer
                              ? FilledButton.tonalIcon(
                                  onPressed: () {
                                    setState(() {
                                      _showAnswer = true;
                                    });
                                  },
                                  icon: const Icon(Icons.remove_red_eye_rounded),
                                  label: Text(
                                    translate('rounds.reveal_answer'),
                                  ),
                                )
                              : Text(
                                  "(${_currentQuestion.answer})",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.blueGrey.shade200,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    if (_isTimeOver)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton(
                                onPressed: () {
                                  GameManager().addBankedPoints(_roundBankedPoints);
                                  GameManager().determineLinks();
                                  
                                  if (_activePlayers.length == 2) {
                                    // This was the decisive round.
                                    // No one is voted out. Skip voting phase.
                                    GameManager().resetRoundStats();
                                    GameManager().incrementRoundNumber();
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => RoundStart(
                                          players: GameManager().players,
                                          questions: GameManager().allQuestions,
                                          roundNumber: GameManager().roundNumber,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => VotingPhase(
                                          players: widget.players,
                                          strongestLink: GameManager().strongestLink!,
                                          weakestLink: GameManager().weakestLink!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  translate('rounds.next'),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Action Grid
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: isLandscape ? 4.5 : 2.5,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isRoundActive ? _handleCorrect : null,
                              icon: const Icon(Icons.check_circle),
                              label: Text(translate('rounds.correct')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent.shade400,
                                foregroundColor: Colors.black,
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isRoundActive ? _handleWrong : null,
                              icon: const Icon(Icons.cancel),
                              label: Text(translate('rounds.wrong')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.shade400,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: (_isRoundActive && _currentChainIndex > 0) ? _handleBank : null,
                              icon: const Icon(Icons.account_balance),
                              label: Text(translate('rounds.bank')),
                              style: FilledButton.styleFrom(
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _isRoundActive ? _handleBurn : null,
                              icon: const Icon(Icons.local_fire_department),
                              label: Text(translate('rounds.burn')),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.orange, width: 2),
                                foregroundColor: Colors.orange.shade400,
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StartingLightsPainter extends CustomPainter {
  final double progress;
  final int roundNumber;

  StartingLightsPainter({required this.progress, required this.roundNumber});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 80.0;
    final lineLength = 30.0;
    final paint = Paint()
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      Color color = Colors.grey.withOpacity(0.1);

      final pairIndex = i % 6;
      if (progress > 0.85) {
        color = Colors.indigo;
      }
      else if (progress > (pairIndex + 2) * 0.1) {
        color = Colors.lightBlueAccent;
      }

      paint.color = color;
      final start = Offset(
        center.dx + (radius - lineLength / 2) * math.cos(angle),
        center.dy + (radius - lineLength / 2) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius + lineLength / 2) * math.cos(angle),
        center.dy + (radius + lineLength / 2) * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: "ROUND $roundNumber",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant StartingLightsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
