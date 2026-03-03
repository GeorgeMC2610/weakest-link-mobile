import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weakest_link/classes/question_collection.dart';
import 'package:weakest_link/classes/question.dart';
import 'package:weakest_link/seeds/default_collection.dart';

class QuestionService {
  static const String _boxName = 'question_collections';

  static Future<void> init() async {
    await Hive.openBox<QuestionCollection>(_boxName);

    // Refresh default collection in debug mode to ensure latest seed data is used
    if (kDebugMode) {
      final existing = _box.values.where((c) => c.title == DefaultQuestionCollection.getDefaultSeed().title).toList();
      for (var c in existing) {
        await c.delete();
      }
    }
    
    // Add default collection if it doesn't exist (or was just deleted in debug mode)
    final defaultCollection = getAllCollections().any((c) => c.title == DefaultQuestionCollection.getDefaultSeed().title);
    if (!defaultCollection) {
      await addCollection(DefaultQuestionCollection.getDefaultSeed());
    }
  }

  static Box<QuestionCollection> get _box => Hive.box<QuestionCollection>(_boxName);

  static ValueListenable<Box<QuestionCollection>> get listenable => _box.listenable();

  static List<QuestionCollection> getAllCollections() {
    return _box.values.toList();
  }

  static Future<void> addCollection(QuestionCollection collection) async {
    await _box.add(collection);
  }

  static Future<void> updateCollection(dynamic key, QuestionCollection collection) async {
    await _box.put(key, collection);
  }

  static Future<void> deleteCollection(QuestionCollection collection) async {
    await collection.delete();
  }
}
