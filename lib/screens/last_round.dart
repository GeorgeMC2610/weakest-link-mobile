import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weakest_link/classes/player.dart';
import 'package:weakest_link/classes/question.dart';
import 'package:weakest_link/services/game_manager.dart';

class LastRound extends StatefulWidget {
  final List<Player> finalists;
  final int grandPrize;
  final List<Question> allQuestions;

  const LastRound({
    super.key,
    required this.finalists,
    required this.grandPrize,
    required this.allQuestions,
  });

  @override
  State<LastRound> createState() => _LastRoundState();
}

class _LastRoundState extends State<LastRound> {
  int _currentPlayerIndex = 0;
  final List<bool?> _player1Results = List.filled(5, null, growable: true);
  final List<bool?> _player2Results = List.filled(5, null, growable: true);

  int _p1Correct = 0;
  int _p2Correct = 0;
  int _p1Asked = 0;
  int _p2Asked = 0;

  bool _isSuddenDeath = false;
  Player? _winner;

  late Question _currentQuestion;

  bool _showAnswer = false;
  bool get showAnswer => GameManager().hostMode ? true : _showAnswer;

  @override
  void initState() {
    super.initState();
    _currentQuestion = GameManager().getNextFinalQuestion();
  }

  void _handleAnswer(bool isCorrect) {
    if (_winner != null) return;

    setState(() {
      _showAnswer = false;
      if (_currentPlayerIndex == 0) {
        if (_isSuddenDeath && _p1Asked >= 5) {
          _player1Results.add(isCorrect);
        } else {
          _player1Results[_p1Asked] = isCorrect;
        }
        if (isCorrect) _p1Correct++;
        _p1Asked++;
        _currentPlayerIndex = 1;
      } else {
        if (_isSuddenDeath && _p2Asked >= 5) {
          _player2Results.add(isCorrect);
        } else {
          _player2Results[_p2Asked] = isCorrect;
        }
        if (isCorrect) _p2Correct++;
        _p2Asked++;
        _currentPlayerIndex = 0;
      }

      _currentQuestion = GameManager().getNextFinalQuestion();
      _checkGameState();
    });
  }

  void _checkGameState() {
    if (!_isSuddenDeath) {
      int p1Remaining = 5 - _p1Asked;
      int p2Remaining = 5 - _p2Asked;

      if (_p1Correct > _p2Correct + p2Remaining) {
        _winner = widget.finalists[0];
        return;
      }
      if (_p2Correct > _p1Correct + p1Remaining) {
        _winner = widget.finalists[1];
        return;
      }

      if (_p1Asked == 5 && _p2Asked == 5) {
        if (_p1Correct == _p2Correct) {
          _isSuddenDeath = true;
        } else {
          _winner = _p1Correct > _p2Correct ? widget.finalists[0] : widget.finalists[1];
        }
      }
    } else {
      if (_p1Asked == _p2Asked) {
        int p1SDResult = _player1Results.last == true ? 1 : 0;
        int p2SDResult = _player2Results.last == true ? 1 : 0;

        if (p1SDResult != p2SDResult) {
          _winner = p1SDResult > p2SDResult ? widget.finalists[0] : widget.finalists[1];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = widget.finalists[_currentPlayerIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          translate('rounds.last_round',
              args: {'grand_prize': widget.grandPrize}),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.5),
            radius: 1.1,
            colors: [
              Color(0xFF160B22),
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildScoreBoard(),
              const Spacer(),
              
              if (_winner == null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: currentPlayer.color,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: currentPlayer.color.withOpacity(0.7),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    currentPlayer.name.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  _currentQuestion.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                !showAnswer
                    ? FilledButton.tonalIcon(
                        onPressed: () {
                          setState(() {
                            _showAnswer = true;
                          });
                        },
                        label: Text(translate('rounds.reveal_answer')),
                        icon:
                            const Icon(Icons.remove_red_eye_rounded),
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
                const Spacer(),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleAnswer(true),
                        icon: const Icon(Icons.check_circle, size: 32),
                        label: Text(
                          translate('rounds.correct'),
                          style: const TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade400,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleAnswer(false),
                        icon: const Icon(Icons.cancel, size: 32),
                        label: Text(
                          translate('rounds.wrong'),
                          style: const TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                Text(
                  translate('rounds.winner'),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _winner!.name,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _winner!.color,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  translate('rounds.banked',
                      args: {'points': widget.grandPrize}),
                  style:
                      Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil(
                            (route) => route.isFirst),
                    child:
                        Text(translate('rounds.exit_game')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Column(
      children: [
        _buildPlayerScoreRow(widget.finalists[0], _player1Results),
        const SizedBox(height: 12),
        _buildPlayerScoreRow(widget.finalists[1], _player2Results),
        if (_isSuddenDeath)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              translate('rounds.sudden_death'),
              style: TextStyle(
                color: Colors.red.shade900,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerScoreRow(Player player, List<bool?> results) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            player.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Wrap(
            spacing: 4,
            children: results.map((res) {
              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: res == null
                      ? Colors.grey.shade300
                      : (res ? Colors.green : Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  res == null ? null : (res ? Icons.check : Icons.close),
                  color: Colors.white,
                  size: 20,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
