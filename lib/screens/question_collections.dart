import 'package:flutter/material.dart';
import 'package:weakest_link/classes/question_collection.dart';
import 'package:weakest_link/services/question_service.dart';
import 'package:weakest_link/screens/shared_views/add_collection.dart';

class QuestionCollections extends StatefulWidget {
  const QuestionCollections({super.key});

  @override
  State<QuestionCollections> createState() => _QuestionCollectionsState();
}

class _QuestionCollectionsState extends State<QuestionCollections> {
  List<QuestionCollection> _collections = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  void _loadCollections() {
    setState(() {
      _collections = QuestionService.getAllCollections();
    });
  }

  Future<void> _navigateToAddEdit([QuestionCollection? collection]) async {
    final result = await Navigator.of(context).push<QuestionCollection>(
      MaterialPageRoute(
        builder: (context) => AddCollectionDialog(collection: collection),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      if (collection == null) {
        await QuestionService.addCollection(result);
      } else {
        await QuestionService.updateCollection(collection.key, result);
      }
      _loadCollections();
    }
  }

  Future<void> _deleteCollection(QuestionCollection collection) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text('Are you sure you want to delete "${collection.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await QuestionService.deleteCollection(collection);
      _loadCollections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Collections'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _collections.isEmpty
          ? const Center(child: Text('No collections found. Add one!'))
          : ListView.builder(
              itemCount: _collections.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final collection = _collections[index];
                return Card(
                  child: ListTile(
                    title: Text(collection.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${collection.questions.length} questions'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToAddEdit(collection),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCollection(collection),
                        ),
                      ],
                    ),
                    onTap: () => _navigateToAddEdit(collection),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(),
        label: const Text('New Collection'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
