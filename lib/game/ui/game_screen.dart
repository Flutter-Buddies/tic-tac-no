import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_no/game/bloc/game_bloc.dart';
import 'package:tic_tac_no/game/data/models/models.dart';
import 'package:tic_tac_no/game/ui/game_over_dialog.dart';
import 'package:tic_tac_no/game/ui/game_over_draw_line.dart';
import 'package:tic_tac_no/game/ui/grid_widget.dart';
import 'package:tic_tac_no/game/ui/player_column.dart';
import 'package:confetti/confetti.dart';
import 'package:tic_tac_no/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tic_tac_no/utils/audio.dart';

class GameScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late Grid _grid;
  List<Player>? _players;
  Player? _currentPlayer;
  Map<int, int>? _score;

  // Confetti
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    this._grid = BlocProvider.of<GameBloc>(context).getGrid();
    this._players = BlocProvider.of<GameBloc>(context).players;
    this._currentPlayer = BlocProvider.of<GameBloc>(context).getCurrentPlayer();
    this._score = BlocProvider.of<GameBloc>(context).score;
    BlocProvider.of<GameBloc>(context).audio.isMuted =
        context.read<UIAudio>().isMuted;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<bool?> _backFunction() async {
    return showModalBottomSheet<bool?>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xff012E44),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.game_are_you_sure_quit.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(LocaleKeys.game_all_progress_lost.tr()),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<UIAudio>().playSound(UISounds.ButtonClick);
                    Navigator.of(context)
                        .popUntil((route) => route.settings.name == '/');
                    context.read<GameBloc>().add(Reset());
                  },
                  child: Container(
                    height: 48,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: const Color(0xffFF5F6D),
                    ),
                    child: Center(
                      child: Text(
                        LocaleKeys.game_quit_game.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<UIAudio>().playSound(UISounds.ButtonClick);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 48,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xff2A5298),
                    ),
                    child: Center(
                      child: Text(
                        LocaleKeys.game_return_to_game.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGameOver(Player? winner) async {
    // Delay used to give the user a little time to process they won and
    // to give time for animation of line going through 3 winning squares (todo: create this animation 😅)
    await Future.delayed(const Duration(seconds: 3));
    await showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return GameOverDialog(winner: winner);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        if (state is Ready) {
          setState(() {
            this._grid = state.grid;
            this._players = state.players;
            this._currentPlayer = state.currentPlayer;
            this._score = state.score;
          });
          // This is just if the game was reset and the confetti was still going
          _confettiController.stop();
        }

        if (state is GameOver) {
          final winner = state.winner;
          if (winner != null) {
            _confettiController.play();
            // If game was won by ai play game lost sound else play game won sound
            if (winner.aiStrength != null) {
              // context.read<GameAudio>().playSound(SoundEvents.GameLost);
            } else {
              // context.read<GameAudio>().playSound(SoundEvents.GameWon);
            }
          }
          _showGameOver(winner);
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          final shouldPop = await _backFunction();
          if (shouldPop != null && shouldPop) {
            return true;
          }
          return false;
        },
        child: SafeArea(
          top: false,
          child: Scaffold(
            body: Stack(
              children: [
                //* Background
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff1E3C72), Color(0xff2A5298)],
                  )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //* Player info section
                      // Wrapping with expanded because this is the section that will resize based on screen size
                      // and we want to to scale vertically
                      const SizedBox(
                        height: 8.0,
                      ),
                      if (_score != null &&
                          _players != null &&
                          _players!.length >= 2)
                        Expanded(
                          child: Row(
                            // We want the content to be aligned in the center vertically
                            // ignore: avoid_redundant_argument_values
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // The score text will remain a constant size so will not be wrapped in Expanded
                            // The player name, piece and turn info will be the thing that scales
                            children: [
                              // Wrapped in expanded to scale
                              // Currently taking the max width it can
                              const Spacer(),
                              Expanded(
                                flex: 6,
                                child: PlayerColumn(
                                  player: _players![0],
                                  isPlayerTurn: _players![0] == _currentPlayer,
                                ),
                              ),
                              const Spacer(),
                              // Score info remains constant size
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  '${_score![_players![0].id]}',
                                  key: ValueKey<int>(_score![_players![0].id]!),
                                  style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Text(
                                ' : ',
                                style: TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.bold),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  '${_score![_players![1].id]}',
                                  key: ValueKey<int>(_score![_players![1].id]!),
                                  style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              // Wrapped in expanded to scale
                              const Spacer(),
                              Expanded(
                                flex: 6,
                                child: PlayerColumn(
                                  player: _players![1],
                                  isPlayerTurn: _players![1] == _currentPlayer,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      //* Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Stack(
                            children: [
                              GridWidget(
                                grid: this._grid,
                              ),
                              IgnorePointer(child: GameOverDrawLine()),
                            ],
                          ),
                        ),
                      ),
                      //* Button to go back
                      SizedBox(
                        height: 30,
                        child: IconButton(
                          onPressed: () {
                            context
                                .read<UIAudio>()
                                .playSound(UISounds.ButtonClick);
                            _backFunction();
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 30,
                          ),
                        ),
                      ),
                      //? For some reason this has to be here to have the confetti work
                      Container(
                        width: double.infinity,

                        // child: IconButton(
                        //   iconSize: 20,
                        //   icon: Icon(Icons.party_mode),
                        //   onPressed: () {
                        //     _confettiController.play();
                        //   },
                        // ),
                      ),
                    ],
                  ),
                ),
                //* Confetti right
                Align(
                  alignment: Alignment.topRight,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    maxBlastForce: 7,
                    minBlastForce: 2,
                    emissionFrequency: 0.2,
                    numberOfParticles: 3,
                    gravity: 0.3,
                    colors: const [
                      Color(0xff1E3C72),
                      Colors.white,
                      Color(0xffFF5F6D),
                      Color(0xffFFC371),
                      Color(0xffE33E49),
                      Color(0xff9B00B5),
                      Color(0xff9534E1),
                      Color(0xff009E95),
                    ],
                  ),
                ),
                //* Confetti left
                Align(
                  alignment: Alignment.topLeft,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: 0,
                    maxBlastForce: 7,
                    minBlastForce: 2,
                    emissionFrequency: 0.2,
                    numberOfParticles: 3,
                    gravity: 0.3,
                    colors: const [
                      Color(0xff1E3C72),
                      Colors.white,
                      Color(0xffFF5F6D),
                      Color(0xffFFC371),
                      Color(0xffE33E49),
                      Color(0xff9B00B5),
                      Color(0xff9534E1),
                      Color(0xff009E95),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
