import 'package:flutter/material.dart';
import 'package:weakest_link/classes/player.dart';

class GameManager with ChangeNotifier {
  GameManager._internal();
  static final GameManager _instance = GameManager._internal();
  factory GameManager() => _instance;

  GameState _currentState = GameState.notStarted;
  GameState get currentState => _currentState;

  List<Player> _players = [];
  List<Player> get players => _players;
  List<Player> get notEliminatedPlayers => _players.where((p) => !p.isEliminated).toList();
  List<Player> get eliminatedPlayers => _players.where((p) => p.isEliminated).toList();
  Player get strongestLink => _players.firstWhere((p) => p.isStrongestLink);
  Player get weakestLink => _players.firstWhere((p) => p.isWeakestLink);

  void setPlayers(List<Player> players) {
    _players = players;
    notifyListeners();
  }

  void changeState(GameState newState) {
    _currentState = newState;
    notifyListeners();
  }

  void eliminatePlayer(Player player) {
    player.isEliminated = true;
    notifyListeners();
  }

  int _roundNumber = 1;
  int get roundNumber => _roundNumber;

  void incrementRoundNumber() {
    _roundNumber++;
    notifyListeners();
  }

  void determineLinks() {
    final activePlayers = notEliminatedPlayers;
    if (activePlayers.isEmpty) return;

    // Reset previous links
    for (var p in _players) {
      p.isStrongestLink = false;
      p.isWeakestLink = false;
    }

    // Determine Strongest Link
    // 1. Most right answers
    // 2. Most points saved (banked)
    // 3. Fewest wrong answers
    Player strongest = activePlayers[0];
    for (var i = 1; i < activePlayers.length; i++) {
      final p = activePlayers[i];
      if (p.rightAnswers > strongest.rightAnswers) {
        strongest = p;
      } else if (p.rightAnswers == strongest.rightAnswers) {
        if (p.pointsSaved > strongest.pointsSaved) {
          strongest = p;
        } else if (p.pointsSaved == strongest.pointsSaved) {
          if (p.wrongAnswers < strongest.wrongAnswers) {
            strongest = p;
          }
        }
      }
    }
    strongest.isStrongestLink = true;

    // Determine Weakest Link
    // 1. Most wrong answers
    // 2. Least points saved (banked)
    // 3. Fewest right answers
    Player weakest = activePlayers[0];
    for (var i = 1; i < activePlayers.length; i++) {
      final p = activePlayers[i];
      if (p.wrongAnswers > weakest.wrongAnswers) {
        weakest = p;
      } else if (p.wrongAnswers == weakest.wrongAnswers) {
        if (p.pointsSaved < weakest.pointsSaved) {
          weakest = p;
        } else if (p.pointsSaved == weakest.pointsSaved) {
          if (p.rightAnswers < weakest.rightAnswers) {
            weakest = p;
          }
        }
      }
    }
    weakest.isWeakestLink = true;

    notifyListeners();
  }

  void resetRoundStats() {
    for (var p in _players) {
      p.rightAnswers = 0;
      p.wrongAnswers = 0;
      p.pointsSaved = 0;
      p.isStrongestLink = false;
      p.isWeakestLink = false;
    }
    notifyListeners();
  }
}

enum GameState {
  notStarted,
  menu,
  playing,
  voting,
}
