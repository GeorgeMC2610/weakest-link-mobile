import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weakest_link/classes/player.dart';
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
  bool _showLinks = false;
  bool get showLinks => GameManager().hostMode ? true : _showLinks;

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
        title: Text(translate('voting.tie_title')),
        content: Text(translate('voting.tie_desc', args: {
          'players': tiedPlayers.map((p) => p.name).join(", "),
          'link': widget.strongestLink.name
        })),
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
        backgroundColor: Colors.black,
        title: Text(translate('voting.title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetVotes,
            tooltip: translate('voting.reset'),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.2,
            colors: [
              Color(0xFF081226),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    translate('voting.cast'),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    translate('voting.votes', args: {
                      'votes': '$_totalVotes / ${_activePlayers.length}'
                    }),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: _totalVotes == _activePlayers.length
                              ? Colors.greenAccent
                              : Colors.blueGrey.shade300,
                        ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    icon:
                        Icon(showLinks ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showLinks = !_showLinks;
                      });
                    },
                    label: Text(
                      "${_showLinks ? translate('voting.hide') : translate('voting.show')} ${translate('voting.weakest_strongest_links')}",
                    ),
                  )
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
                  
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueGrey.withOpacity(0.35),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                      border: Border.all(
                        color: isWeakest
                            ? Colors.redAccent
                            : (isStrongest
                                ? Colors.cyanAccent
                                : Colors.blueGrey.shade700),
                        width: isWeakest || isStrongest ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => _handleVote(player),
                      onLongPress: () => _handleRemoveVote(player),
                      leading: CircleAvatar(
                        backgroundColor: player.color,
                        child: Text(
                          player.name[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          if (isStrongest && showLinks)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                translate('voting.strongest_link'),
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          if (isWeakest && showLinks)
                            Text(
                              translate('voting.weakest_link'),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (voteCount > 0)
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _handleRemoveVote(player),
                            ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: voteCount > 0
                                  ? Colors.cyanAccent.withOpacity(0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: voteCount > 0
                                    ? Colors.cyanAccent
                                    : Colors.blueGrey.shade600,
                              ),
                            ),
                            child: Text(
                              "$voteCount",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: voteCount > 0
                                        ? Colors.cyanAccent
                                        : Colors.blueGrey.shade300,
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
                  onPressed: _totalVotes == _activePlayers.length
                      ? _confirmVotes
                      : null,
                  child: Text(
                    translate('voting.vote_out'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
