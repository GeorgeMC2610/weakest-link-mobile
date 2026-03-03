import 'package:hive_flutter/hive_flutter.dart';
import 'package:weakest_link/classes/question_collection.dart';
import 'package:weakest_link/classes/question.dart';

class QuestionService {
  static const String _boxName = 'question_collections';

  static Future<void> init() async {
    await Hive.openBox<QuestionCollection>(_boxName);
    
    // Add default collection if empty
    if (getAllCollections().isEmpty) {
      await addCollection(QuestionCollection(
        title: 'General Knowledge',
        questions: [
          Question(title: 'What is the capital of France?', answer: 'Paris', difficulty: 1),
          Question(title: 'Who wrote Hamlet?', answer: 'Shakespeare', difficulty: 2),
        ],
      ));
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
