import 'package:flutter/material.dart';

class Player {
  final String name;
  final Color color;

  Player({required this.name, required this.color});
}

class AddPlayerDialog extends StatefulWidget {
  const AddPlayerDialog({super.key});

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _nameController = TextEditingController();
  double _r = 155;
  double _g = 155;
  double _b = 155;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = Color.fromARGB(255, _r.toInt(), _g.toInt(), _b.toInt());

    return AlertDialog(
      title: const Text('Add New Player'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                hintText: 'Enter name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Selected Color: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRGBSlider('R', _r, Colors.red, (val) => setState(() => _r = val)),
            _buildRGBSlider('G', _g, Colors.green, (val) => setState(() => _g = val)),
            _buildRGBSlider('B', _b, Colors.blue, (val) => setState(() => _b = val)),
          ],
        ),
      ),
      actions: [
        FilledButton.tonalIcon(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer
          ),
          label: const Text('Close'),
          icon: const Icon(Icons.close)
        ),
        FilledButton.tonalIcon(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              Navigator.of(context).pop(
                Player(name: name, color: currentColor),
              );
            }
          },
          label: const Text('Add Player'),
          icon: const Icon(Icons.add)
        ),
      ],
    );
  }

  Widget _buildRGBSlider(String label, double value, Color activeColor, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold)),
            Text(value.toInt().toString()),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 255,
          activeColor: activeColor,
          inactiveColor: activeColor.withOpacity(0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
