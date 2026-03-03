import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weakest_link/classes/player.dart';

class PlayerService {
  static const String _boxName = 'players';

  static Future<void> init() async {
    await Hive.openBox<Player>(_boxName);
  }

  static Box<Player> get _box => Hive.box<Player>(_boxName);

  static ValueListenable<Box<Player>> get listenable => _box.listenable();

  static List<Player> getAllPlayers() {
    return _box.values.toList();
  }

  static Future<void> addPlayer(Player player) async {
    await _box.add(player);
  }

  static Future<void> deletePlayer(Player player) async {
    await player.delete();
  }

  static Future<void> updatePlayer(Player player) async {
    await player.save();
  }
}
