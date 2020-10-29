import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:tictactoe/controllers/game_controller.dart';
import 'package:tictactoe/core/constants.dart';
import 'package:tictactoe/enums/player_type.dart';
import 'package:tictactoe/enums/winner_type.dart';
import 'package:tictactoe/widgets/custom_dialog.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _controller = GameController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  _buildAppBar() {
    return AppBar(
      title: Text(GAME_TITLE),
      centerTitle: true,
    );
  }

  _buildBody() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBoard(),
          _buildVerticalSpace(height: 10),
          _buildCurrentPlayer(_controller.name),
          _buildCurrentScore(
              _controller.wp1.toString(), _controller.wp2.toString()),
          _buildShareButton(),
          _buildPlayerMode(),
          _buildResetButton(),
        ],
      ),
    );
  }

  _buildResetButton() {
    return RaisedButton(
      padding: const EdgeInsets.all(20),
      child: Text(RESET_BUTTON_LABEL),
      onPressed: _onResetGame,
    );
  }

  _buildBoard() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: BOARD_SIZE,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: _buildTile,
      ),
    );
  }

  _buildPlayerMode() {
    return SwitchListTile(
      title: Text(_controller.isSinglePlayer ? 'SinglePlayer' : 'MultiPlayer'),
      secondary: Icon(_controller.isSinglePlayer ? Icons.person : Icons.group),
      value: _controller.isSinglePlayer,
      onChanged: (value) {
        setState(() {
          _controller.isSinglePlayer = value;
        });
      },
    );
  }

  _buildCurrentPlayer(String player) {
    if (player == null) {
      player = 'Ninguém';
    }
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.2),
      height: 40,
      child: Center(
        child: Text(
          'Jogando agora: $player',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  _buildCurrentScore(String scorePlayer1, String scorePlayer2) {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.2),
      height: 40,
      child: Center(
        child: Text(
          'Player 1: $scorePlayer1   X   Player 2: $scorePlayer2',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  _buildVerticalSpace({double height = 20.0}) {
    return SizedBox(height: height);
  }

  _buildShareButton() {
    return RaisedButton(
      padding: const EdgeInsets.all(20),
      child: Text(SHARE_BUTTON_LABEL),
      onPressed: _onShare,
    );
  }

  Widget _buildTile(context, index) {
    return GestureDetector(
      onTap: () => _onMarkTile(index),
      child: Container(
        color: _controller.tiles[index].color,
        child: Center(
          child: Image.asset(
            _controller.tiles[index].symbol,
          ),
        ),
      ),
    );
  }

  _onResetGame() {
    setState(() {
      _controller.reset();
    });
  }

  _onShare() {
    Share.share(
        'See my project on Github - https://github.com/lpmelo/tic-tac-toe-flutter');
  }

  _onMarkTile(index) {
    if (!_controller.tiles[index].enable) return;

    setState(() {
      _controller.markBoardTileByIndex(index);
    });

    _checkWinner();
  }

  _checkWinner() {
    var winner = _controller.checkWinner();
    if (winner == WinnerType.none) {
      if (!_controller.hasMoves) {
        _showTiedDialog();
      } else if (_controller.isSinglePlayer &&
          _controller.currentPlayer == PlayerType.player2) {
        final index = _controller.automaticMove();
        _onMarkTile(index);
      }
    } else {
      String symbol = winner == WinnerType.player1 ? 'Player 1' : 'Player 2';
      _showWinnerDialog(symbol);
    }
  }

  _showWinnerDialog(String symbol) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CustomDialog(
          title: WIN_TITLE.replaceAll('[SYMBOL]', symbol),
          message: DIALOG_MESSAGE,
          onPressed: _onResetGame,
        );
      },
    );
  }

  _showTiedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CustomDialog(
          title: TIED_TITLE,
          message: DIALOG_MESSAGE,
          onPressed: _onResetGame,
        );
      },
    );
  }
}
