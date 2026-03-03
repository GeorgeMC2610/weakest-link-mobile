import 'package:flutter/material.dart';
import 'package:weakest_link/classes/player.dart';

class GameManager with ChangeNotifier {
  GameManager._internal();
  static final GameManager _instance = GameManager._internal();
  factory GameManager() => _instance;

  List<Player> _players = [];
  List<Player> get players => _players;

  void setPlayers(List<Player> players) {
    _players = players;
    notifyListeners();
  }

  int _roundNumber = 1;
  int get roundNumber => _roundNumber;

  void incrementRoundNumber() {
    _roundNumber++;
    notifyListeners();
  }
}

enum GameState {
  notStarted,
  menu,
  playing,
  voting,
}