import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weakest_link/classes/question_collection.dart';

class CollectionsTab extends StatelessWidget {
  final List<QuestionCollection> allCollections;
  final List<QuestionCollection> selectedCollections;
  final Function(QuestionCollection, bool) onToggleSelection;
  final VoidCallback onAddCollection;

  const CollectionsTab({
    super.key,
    required this.allCollections,
    required this.selectedCollections,
    required this.onToggleSelection,
    required this.onAddCollection,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              ...allCollections.map((collection) {
                final isSelected = selectedCollections.contains(collection);
                final count = collection.questions.length;
                return FilterChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(collection.title),
                      Text(
                        '$count ${translate("home.questions").toLowerCase()}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) => onToggleSelection(collection, selected),
                );
              }),
              ActionChip(
                avatar: const Icon(Icons.menu),
                label: Text(translate('questions.manage')),
                onPressed: onAddCollection,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
