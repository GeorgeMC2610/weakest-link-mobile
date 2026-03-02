import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  final bool isTimerEnabled;
  final bool isSoundEnabled;
  final ValueChanged<bool> onTimerChanged;
  final ValueChanged<bool> onSoundChanged;

  const SettingsTab({
    super.key,
    required this.isTimerEnabled,
    required this.isSoundEnabled,
    required this.onTimerChanged,
    required this.onSoundChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Timer Enabled'),
          value: isTimerEnabled,
          onChanged: onTimerChanged,
        ),
        SwitchListTile(
          title: const Text('Sound Effects'),
          value: isSoundEnabled,
          onChanged: onSoundChanged,
        ),
        const ListTile(
          title: Text('Difficulty'),
          trailing: Text('Medium'),
        ),
        const ListTile(
          title: Text('Language'),
          trailing: Text('English'),
        ),
      ],
    );
  }
}
