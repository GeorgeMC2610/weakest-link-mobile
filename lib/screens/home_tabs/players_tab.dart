import 'package:flutter/material.dart';
import 'package:weakest_link/screens/shared_views/add_player.dart';
import 'dart:math' as math;

import '../../classes/player.dart';

class PlayersTab extends StatelessWidget {
  final List<Player> allPlayers;
  final List<Player> selectedPlayers;
  final bool isEditing;
  final AnimationController shakeController;
  final Function(Player) onToggleSelection;
  final VoidCallback onToggleEditing;
  final Function(Player) onAddPlayer;
  final Function(Player) onDeletePlayer;

  const PlayersTab({
    super.key,
    required this.allPlayers,
    required this.selectedPlayers,
    required this.isEditing,
    required this.shakeController,
    required this.onToggleSelection,
    required this.onToggleEditing,
    required this.onAddPlayer,
    required this.onDeletePlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ...allPlayers.map((player) {
                    final isSelected = selectedPlayers.contains(player);

                    Widget chipContent = FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(player.name),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: player.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        if (!isEditing) {
                          onToggleSelection(player);
                        }
                      },
                    );

                    if (isEditing) {
                      chipContent = AnimatedBuilder(
                        animation: shakeController,
                        builder: (context, child) {
                          final angle = (math.pi / 180) * 1.5 * shakeController.value;
                          return Transform.rotate(
                            angle: shakeController.status == AnimationStatus.forward ? angle : -angle,
                            child: child,
                          );
                        },
                        child: chipContent,
                      );
                    }

                    return LongPressDraggable<Player>(
                      data: player,
                      // When already editing, we want the drag to start immediately.
                      // When not editing, we wait for a long press to trigger edit mode and drag.
                      delay: isEditing ? Duration.zero : const Duration(milliseconds: 500),
                      feedback: Material(
                        color: Colors.transparent,
                        child: Opacity(
                          opacity: 0.8,
                          child: chipContent,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: chipContent,
                      ),
                      onDragStarted: () {
                        if (!isEditing) onToggleEditing();
                      },
                      // AbsorbPointer prevents the FilterChip from stealing gestures during drag/edit
                      child: AbsorbPointer(
                        absorbing: isEditing,
                        child: chipContent,
                      ),
                    );
                  }),
                  if (!isEditing)
                    ActionChip(
                      avatar: const Icon(Icons.add),
                      label: const Text('Add'),
                      onPressed: () async {
                        final newPlayer = await showDialog<Player>(
                          context: context,
                          builder: (context) => const AddPlayerDialog(),
                        );
                        if (newPlayer != null) {
                          onAddPlayer(newPlayer);
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        if (isEditing)
          Align(
            alignment: Alignment.bottomCenter,
            child: DragTarget<Player>(
              onAcceptWithDetails: (details) {
                onDeletePlayer(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                    border: Border(top: BorderSide(color: candidateData.isNotEmpty ? Colors.red : Colors.grey.shade400)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        color: candidateData.isNotEmpty ? Colors.red : Colors.grey,
                        size: candidateData.isNotEmpty ? 48 : 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Drop here to delete',
                        style: TextStyle(
                          color: candidateData.isNotEmpty ? Colors.red : Colors.grey,
                          fontWeight: candidateData.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
