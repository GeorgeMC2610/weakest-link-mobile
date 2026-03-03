import 'package:flutter/material.dart';
import '../classes/question.dart';
import '../classes/question_collection.dart';
import '../services/question_service.dart';

class QuestionCollectionForm extends StatefulWidget {
  final QuestionCollection? collection;
  const QuestionCollectionForm({super.key, this.collection});

  @override
  State<QuestionCollectionForm> createState() => _QuestionCollectionFormState();
}

class _QuestionCollectionFormState extends State<QuestionCollectionForm> {

  final _titleController = TextEditingController();
  final List<Question> _questions = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.collection != null) {
      _titleController.text = widget.collection!.title;
      _questions.addAll(widget.collection!.questions.map((q) => Question(
        title: q.title,
        answer: q.answer,
        difficulty: q.difficulty,
      )));
    } else {
      // Start with one empty question
      _addQuestion();
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add(Question(title: '', answer: '', difficulty: 1));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one question')),
        );
        return;
      }

      final newCollection = QuestionCollection(
        title: _titleController.text.trim(),
        questions: _questions,
      );

      Navigator.of(context).pop(newCollection);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection == null ? 'New Collection' : 'Edit Collection'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Collection Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  // Check uniqueness if it's a new collection or title changed
                  if (widget.collection == null || value.trim() != widget.collection!.title) {
                    final exists = QuestionService.getAllCollections().any(
                          (c) => c.title.toLowerCase() == value.trim().toLowerCase(),
                    );
                    if (exists) return 'Title already exists';
                  }
                  return null;
                },
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Question ${index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeQuestion(index),
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: _questions[index].title,
                            decoration: const InputDecoration(labelText: 'Question'),
                            onChanged: (val) => _questions[index] = Question(
                              title: val,
                              answer: _questions[index].answer,
                              difficulty: _questions[index].difficulty,
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                          TextFormField(
                            initialValue: _questions[index].answer,
                            decoration: const InputDecoration(labelText: 'Answer'),
                            onChanged: (val) => _questions[index] = Question(
                              title: _questions[index].title,
                              answer: val,
                              difficulty: _questions[index].difficulty,
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Difficulty: '),
                              Expanded(
                                child: Slider(
                                  value: _questions[index].difficulty.toDouble(),
                                  min: 1,
                                  max: 5,
                                  divisions: 4,
                                  label: _questions[index].difficulty.toString(),
                                  onChanged: (val) {
                                    setState(() {
                                      _questions[index] = Question(
                                        title: _questions[index].title,
                                        answer: _questions[index].answer,
                                        difficulty: val.toInt(),
                                      );
                                    });
                                  },
                                ),
                              ),
                              Text(_questions[index].difficulty.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        label: const Text('Add Question'),
        icon: const Icon(Icons.add),
      ),
    );
  }

}