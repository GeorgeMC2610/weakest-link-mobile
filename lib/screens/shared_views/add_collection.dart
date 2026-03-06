import 'package:flutter/material.dart';
import 'package:weakest_link/classes/question.dart';
import 'package:weakest_link/classes/question_collection.dart';
import 'package:weakest_link/services/question_service.dart';

class AddCollectionDialog extends StatefulWidget {
  final QuestionCollection? collection;

  const AddCollectionDialog({super.key, this.collection});

  @override
  State<AddCollectionDialog> createState() => _AddCollectionDialogState();
}

class _AddCollectionDialogState extends State<AddCollectionDialog> {
  final _titleController = TextEditingController();
  final List<Question> _questions = [];
  final _formKey = GlobalKey<FormState>();

  int _currentPage = 0;
  static const int _questionsPerPage = 5;

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
      // Jump to the newly created question's page
      _currentPage = (_questions.length - 1) ~/ _questionsPerPage;
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      // Adjust page index if necessary
      int maxPage = (_questions.length - 1) ~/ _questionsPerPage;
      if (_currentPage > maxPage && maxPage >= 0) {
        _currentPage = maxPage;
      } else if (_questions.isEmpty) {
        _currentPage = 0;
      }
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
    final totalPages = (_questions.length / _questionsPerPage).ceil();
    final startIndex = _currentPage * _questionsPerPage;
    final endIndex = (startIndex + _questionsPerPage < _questions.length)
        ? startIndex + _questionsPerPage
        : _questions.length;
    
    final visibleQuestions = _questions.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection == null ? 'New Collection' : 'Edit Collection'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: visibleQuestions.length,
                itemBuilder: (context, index) {
                  final actualIndex = startIndex + index;
                  return Card(
                    key: ValueKey(_questions[actualIndex]),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Question ${actualIndex + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeQuestion(actualIndex),
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: _questions[actualIndex].title,
                            decoration: const InputDecoration(labelText: 'Question'),
                            onChanged: (val) => _questions[actualIndex] = Question(
                              title: val,
                              answer: _questions[actualIndex].answer,
                              difficulty: _questions[actualIndex].difficulty,
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                          TextFormField(
                            initialValue: _questions[actualIndex].answer,
                            decoration: const InputDecoration(labelText: 'Answer'),
                            onChanged: (val) => _questions[actualIndex] = Question(
                              title: _questions[actualIndex].title,
                              answer: val,
                              difficulty: _questions[actualIndex].difficulty,
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Difficulty: '),
                              Expanded(
                                child: Slider(
                                  value: _questions[actualIndex].difficulty.toDouble(),
                                  min: 1,
                                  max: 5,
                                  divisions: 4,
                                  label: _questions[actualIndex].difficulty.toString(),
                                  onChanged: (val) {
                                    setState(() {
                                      _questions[actualIndex] = Question(
                                        title: _questions[actualIndex].title,
                                        answer: _questions[actualIndex].answer,
                                        difficulty: val.toInt(),
                                      );
                                    });
                                  },
                                ),
                              ),
                              Text(_questions[actualIndex].difficulty.toString()),
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
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
              ),
              Text(
                'Page ${_currentPage + 1} / ${totalPages == 0 ? 1 : totalPages}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
