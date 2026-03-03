import 'package:hive_flutter/hive_flutter.dart';
import 'package:weakest_link/classes/question_collection.dart';
import 'package:weakest_link/classes/question.dart';
import 'package:weakest_link/seeds/default_collection.dart';

class QuestionService {
  static const String _boxName = 'question_collections';

  static Future<void> init() async {
    await Hive.openBox<QuestionCollection>(_boxName);
    
    // Add default collection if empty
    final defaultCollection = getAllCollections().any((c) => c.title == DefaultQuestionCollection.getDefaultSeed().title);
    if (!defaultCollection) {
      await addCollection(DefaultQuestionCollection.getDefaultSeed());
    }
  }

  static Box<QuestionCollection> get _box => Hive.box<QuestionCollection>(_boxName);

  static List<QuestionCollection> getAllCollections() {
    return _box.values.toList();
  }

  static Future<void> addCollection(QuestionCollection collection) async {
    await _box.add(collection);
  }

  static Future<void> deleteCollection(QuestionCollection collection) async {
    await collection.delete();
  }
}
