import 'package:flutter/material.dart';

class Player {
  final String name;
  final Color color;
  bool isEliminated;

  Player({required this.name, required this.color, this.isEliminated = false});
}