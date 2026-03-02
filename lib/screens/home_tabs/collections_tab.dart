import 'package:flutter/material.dart';

class CollectionsTab extends StatelessWidget {
  final List<String> allCollections;
  final List<String> selectedCollections;
  final Function(String, bool) onToggleSelection;
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
              ...allCollections.map((item) {
                final isSelected = selectedCollections.contains(item);
                final count = (item.length * 7) % 50 + 10;
                return FilterChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item),
                      Text(
                        '$count questions',
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
                  onSelected: (selected) => onToggleSelection(item, selected),
                );
              }),
              ActionChip(
                avatar: const Icon(Icons.add),
                label: const Text('Add'),
                onPressed: onAddCollection,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
