import 'package:flutter/material.dart';
import 'package:weakest_link/classes/player.dart';
import 'package:weakest_link/screens/last_round.dart';
import 'package:weakest_link/screens/round_start.dart';
import 'package:weakest_link/services/game_manager.dart';

class VotingPhase extends StatefulWidget {
  final List<Player> players;
  final Player strongestLink;
  final Player weakestLink;

  const VotingPhase({
    super.key,
    required this.players,
    required this.strongestLink,
    required this.weakestLink,
  });

  @override
  State<VotingPhase> createState() => _VotingPhaseState();
}

class _VotingPhaseState extends State<VotingPhase> {
  late Map<Player, int> _votes;
  late List<Player> _activePlayers;

  @override
  void initState() {
    super.initState();
    _activePlayers = widget.players.where((p) => !p.isEliminated).toList();
    _votes = {for (var p in _activePlayers) p: 0};
  }

  int get _totalVotes => _votes.values.fold(0, (sum, v) => sum + v);

  void _handleVote(Player player) {
    if (_totalVotes < _activePlayers.length) {
      setState(() {
        _votes[player] = (_votes[player] ?? 0) + 1;
      });
    }
  }

  void _handleRemoveVote(Player player) {
    setState(() {
      if ((_votes[player] ?? 0) > 0) {
        _votes[player] = _votes[player]! - 1;
      }
    });
  }

  void _resetVotes() {
    setState(() {
      _votes = {for (var p in _activePlayers) p: 0};
    });
  }

  void _confirmVotes() {
    // Update votes count in player objects before proceeding
    _votes.forEach((player, count) {
      player.votes = count;
    });

    int maxVotes = _votes.values.reduce((a, b) => a > b ? a : b);
    List<Player> tiedPlayers = _votes.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();

    if (tiedPlayers.length > 1) {
      _showTieBreakerDialog(tiedPlayers);
    } else {
      _eliminatePlayer(tiedPlayers.first);
    }
  }

  void _eliminatePlayer(Player player) {
    // 1. Mark as eliminated in the Game Manager
    GameManager().eliminatePlayer(player);
    
    // 2. Clear round specific stats for the next round
    GameManager().resetRoundStats();

    // 3. Go to next round start
    GameManager().incrementRoundNumber();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => RoundStart(
          players: GameManager().players,
          questions: GameManager().allQuestions,
          roundNumber: GameManager().roundNumber,
        ),
      ),
      (route) => route.isFirst, // Keep the Home screen at the bottom
    );
  }

  void _showTieBreakerDialog(List<Player> tiedPlayers) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("TIE BREAKER!"),
        content: Text("There's a tie between ${tiedPlayers.map((p) => p.name).join(", ")}. ${widget.strongestLink.name}, as the Strongest Link, must decide who is eliminated."),
        actions: tiedPlayers.map((p) => TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _eliminatePlayer(p);
          },
          child: Text(p.name),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voting Phase"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetVotes,
            tooltip: "Reset Votes",
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "CAST THE VOTES",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Votes: $_totalVotes / ${_activePlayers.length}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _totalVotes == _activePlayers.length ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _activePlayers.length,
              itemBuilder: (context, index) {
                final player = _activePlayers[index];
                final isStrongest = player == widget.strongestLink;
                final isWeakest = player == widget.weakestLink;
                final voteCount = _votes[player] ?? 0;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    onTap: () => _handleVote(player),
                    onLongPress: () => _handleRemoveVote(player),
                    leading: CircleAvatar(
                      backgroundColor: player.color,
                      child: Text(player.name[0], style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Row(
                      children: [
                        if (isStrongest) 
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Text("STRONGEST LINK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        if (isWeakest) 
                          const Text("WEAKEST LINK", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (voteCount > 0)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => _handleRemoveVote(player),
                          ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: voteCount > 0 ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "$voteCount",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: voteCount > 0 ? Theme.of(context).colorScheme.onPrimaryContainer : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                onPressed: _totalVotes == _activePlayers.length ? _confirmVotes : null,
                child: const Text("VOTE OUT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
