import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const BlokusApp());

const _navy = Color(0xff101827);
const _panel = Color(0xff182337);
const _grid = Color(0xff25334a);
const _gold = Color(0xfff5a524);
const _blue = Color(0xff56b4d3);
const _red = Color(0xffef6f61);

class BlokusApp extends StatelessWidget {
  const BlokusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CUBIC BLOCKS',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _gold,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.grid_4x4_rounded,
                      color: _navy,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'CUBIC BLOCKS',
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  const Text(
                    'ひらめきで、つなぐ。',
                    style: TextStyle(
                      color: Color(0xff9aa8bd),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 58),
                  _menuButton(
                    context,
                    '対戦する',
                    Icons.sports_esports_rounded,
                    () => _showModeDialog(context),
                  ),
                  const SizedBox(height: 14),
                  _menuButton(
                    context,
                    'ルールを見る',
                    Icons.menu_book_rounded,
                    () => _showRules(context),
                    outlined: true,
                  ),
                  const SizedBox(height: 42),
                  const Text(
                    '2 PLAYERS  •  11 × 11 FIELD',
                    style: TextStyle(
                      color: Color(0xff687891),
                      fontSize: 11,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool outlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  void _showModeDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('対戦モードを選択'),
        content: const Text('2人で対戦するか、CPUと対戦するか選んでください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('PvP'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('PvE'),
          ),
        ],
      ),
    ).then((isCpu) {
      if (!context.mounted || isCpu == null) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MatchPage(isCpu: isCpu)),
      );
    });
  }

  void _showRules(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ブロックスのルール'),
        content: const SingleChildScrollView(
          child: Text(
            '2人で交互にブロックを置きます。\n\n'
            '• 先攻は11行6列、後攻は1行6列に最初のブロックを置きます。\n'
            '• 2回目以降は、自分のブロックの辺に接する場所だけ置けます。\n'
            '• ブロックは重ねられません。置けないときはスキップします。\n'
            '• 向きを変えて置くとエネルギーを1消費します。\n'
            '• 自分のブロックと接した辺1つにつき100ポイントです。\n'
            '• 手札がなくなるか、両者が置けなくなると終了します。',
            style: TextStyle(height: 1.65, color: Color(0xffc8d1df)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

class MatchPage extends StatefulWidget {
  const MatchPage({super.key, required this.isCpu});

  final bool isCpu;

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late MatchState _match;
  int _selectedPiece = 0;
  int _rotation = 0;
  int? _previewRow;
  int? _previewCol;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _match = MatchState(widget.isCpu, Random());
  }

  Player get _currentPlayer => _match.players[_match.turn];

  void _selectPiece(int index) {
    if (_busy || _currentPlayer.hand[index].used) return;
    setState(() {
      _selectedPiece = index;
      _rotation = 0;
      _clearPreview();
      _match.message = '置きたいマスをタップ';
    });
  }

  void _rotate() {
    if (_busy) return;
    setState(() {
      _rotation = (_rotation + 1) % 4;
      _clearPreview();
      _match.message = '向きを変えました。置きたいマスをタップ';
    });
  }

  void _place(int row, int col) {
    if (_busy || _match.finished) return;
    if (_previewRow == row && _previewCol == col) {
      final result = _match.tryPlace(_selectedPiece, _rotation, row, col);
      if (!result.success) {
        setState(() => _match.message = result.message);
        return;
      }
      setState(() {
        _clearPreview();
        _rotation = 0;
        _selectedPiece = 0;
      });
      _nextTurn();
      return;
    }
    final preview = _match.previewPlacement(
      _selectedPiece,
      _rotation,
      row,
      col,
    );
    if (!preview.success) {
      setState(() {
        _clearPreview();
        _match.message = preview.message;
      });
      return;
    }
    setState(() {
      _previewRow = row;
      _previewCol = col;
      _match.message = '影を確認して、もう一度タップで確定';
    });
  }

  void _clearPreview() {
    _previewRow = null;
    _previewCol = null;
  }

  bool _isPreviewCell(int row, int col) {
    if (_previewRow == null || _previewCol == null) return false;
    final preview = _match.previewPlacement(
      _selectedPiece,
      _rotation,
      _previewRow!,
      _previewCol!,
    );
    return preview.success &&
        preview.positions.any(
          (position) => position[0] == row && position[1] == col,
        );
  }

  void _skip() {
    if (_busy || _match.finished) return;
    setState(() {
      _clearPreview();
      _match.skipTurn();
    });
    _nextTurn();
  }

  void _nextTurn() {
    if (_match.finished) {
      _showResult();
      return;
    }
    if (widget.isCpu && _match.turn == 1) {
      setState(() => _busy = true);
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (!mounted) return;
        _match.cpuMove();
        setState(() => _busy = false);
        if (_match.finished) {
          _showResult();
        }
      });
    }
  }

  void _showResult() {
    if (!mounted) return;
    Future<void>.delayed(Duration.zero, () {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(_match.resultTitle),
          content: Text(
            '${_match.players[0].name}: ${_match.players[0].score} pt\n${_match.players[1].name}: ${_match.players[1].score} pt',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('メイン画面へ'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('対戦中', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () => _showRules(context),
            icon: const Icon(Icons.menu_book_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 30,
              ),
              child: Column(
                children: [
                  _playerPanel(_match.players[1]),
                  const SizedBox(height: 9),
                  _turnBanner(),
                  const SizedBox(height: 10),
                  _buildBoard(),
                  const SizedBox(height: 9),
                  _playerPanel(_match.players[0]),
                  const SizedBox(height: 8),
                  _controls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _playerPanel(Player player) {
    final active = player.id == _match.turn;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? player.color.withAlpha(35) : _panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: active ? player.color : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: player.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                player.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${player.score} pt',
                style: TextStyle(
                  color: player.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.bolt_rounded, color: _gold, size: 17),
              Text(
                '${player.energy}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              player.hand.length,
              (index) => _handPiece(player, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _handPiece(Player player, int index) {
    final piece = player.hand[index];
    final canSelect =
        player.id == _match.turn && (!widget.isCpu || player.id == 0);
    final selected = canSelect && index == _selectedPiece && !piece.used;
    return GestureDetector(
      onTap: canSelect ? () => _selectPiece(index) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 43,
        height: 44,
        decoration: BoxDecoration(
          color: piece.used
              ? _navy
              : (selected ? const Color(0xff344662) : _navy),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? piece.color : const Color(0xff33425b),
            width: selected ? 2 : 1,
          ),
        ),
        child: piece.used
            ? const Icon(
                Icons.check_rounded,
                size: 17,
                color: Color(0xff506079),
              )
            : Center(child: _preview(piece)),
      ),
    );
  }

  Widget _preview(HandPiece piece) {
    final shape = piece.shape;
    final maxRow = shape.map((c) => c[0]).reduce(max);
    final maxCol = shape.map((c) => c[1]).reduce(max);
    return SizedBox(
      width: (maxCol + 1) * 7.0,
      height: (maxRow + 1) * 7.0,
      child: Stack(
        children: shape
            .map(
              (c) => Positioned(
                left: c[1] * 7,
                top: c[0] * 7,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: piece.color,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _turnBanner() => Row(
    children: [
      Icon(
        _busy ? Icons.hourglass_top_rounded : Icons.touch_app_rounded,
        color: _currentPlayer.color,
        size: 18,
      ),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          _busy
              ? 'CPUが考えています…'
              : '${_currentPlayer.name}のターン  ・  ${_match.message}',
          style: const TextStyle(color: Color(0xffc7d0df), fontSize: 12),
        ),
      ),
    ],
  );

  Widget _buildBoard() => AspectRatio(
    aspectRatio: 1,
    child: Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _grid,
        borderRadius: BorderRadius.circular(15),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 11,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 121,
        itemBuilder: (context, index) {
          final cell = _match.board[index];
          return GestureDetector(
            onTap: () => _place(index ~/ 11, index % 11),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              decoration: BoxDecoration(
                color: _isPreviewCell(index ~/ 11, index % 11)
                    ? _currentPlayer.color.withAlpha(125)
                    : (cell == null ? _navy : _match.players[cell].color),
                borderRadius: BorderRadius.circular(3),
              ),
              child: _isPreviewCell(index ~/ 11, index % 11)
                  ? const Icon(Icons.circle, size: 5, color: Color(0x80ffffff))
                  : (cell == null
                        ? null
                        : const Icon(
                            Icons.circle,
                            size: 5,
                            color: Color(0x40000000),
                          )),
            ),
          );
        },
      ),
    ),
  );

  Widget _controls() => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _busy ? null : _rotate,
          icon: const Icon(Icons.rotate_right_rounded),
          label: const Text('回転'),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: FilledButton.icon(
          onPressed: _busy ? null : _skip,
          icon: const Icon(Icons.skip_next_rounded),
          label: const Text('スキップ'),
        ),
      ),
    ],
  );

  void _showRules(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('ルール'),
      content: const SingleChildScrollView(
        child: Text(
          '交互にブロックを置きます。先攻は11行6列、後攻は1行6列に最初のブロックが触れるように置きます。2回目以降は自分のブロックの辺に接する場所だけ置けます。\n\n向きを変えて置くとエネルギーを1消費し、接した辺1つにつき100ポイントです。置けないときはスキップし、両者が置けなくなるか手札がなくなると終了します。',
          style: TextStyle(height: 1.6),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    ),
  );
}

class MatchState {
  MatchState(this.isCpu, this.random) {
    players = [
      Player(0, 'PLAYER 1', _blue, _createHand(random)),
      Player(1, isCpu ? 'CPU' : 'PLAYER 2', _red, _createHand(random)),
    ];
  }

  final bool isCpu;
  final Random random;
  final List<int?> board = List<int?>.filled(121, null);
  late final List<Player> players;
  int turn = 0;
  int skippedTurns = 0;
  String message = '手札からブロックを選び、盤面をタップ';
  bool finished = false;

  String get resultTitle {
    if (players[0].score == players[1].score) return '引き分け';
    return players[0].score > players[1].score
        ? 'PLAYER 1の勝利！'
        : '${players[1].name}の勝利！';
  }

  PlacementResult tryPlace(int handIndex, int rotation, int row, int col) {
    final preview = previewPlacement(handIndex, rotation, row, col);
    if (!preview.success) return preview;
    final player = players[turn];
    final piece = player.hand[handIndex];
    final positions = preview.positions;
    final rotated = rotation != 0;
    final touchingEdges = _touchingEdges(player.id, positions);
    for (final p in positions) board[p[0] * 11 + p[1]] = player.id;
    piece.used = true;
    player.score += touchingEdges * 100;
    if (rotated) player.energy--;
    message = '${piece.baseShape.length}マス配置  +${touchingEdges * 100} pt';
    skippedTurns = 0;
    _advance();
    return const PlacementResult(true, '');
  }

  PlacementResult previewPlacement(
    int handIndex,
    int rotation,
    int row,
    int col,
  ) {
    final player = players[turn];
    if (handIndex < 0 ||
        handIndex >= player.hand.length ||
        player.hand[handIndex].used) {
      return const PlacementResult(false, 'そのブロックはもう使っています');
    }
    final piece = player.hand[handIndex];
    if (player.energy == 0)
      return const PlacementResult(false, 'エネルギーが0なので置けません');
    final cells = rotate(
      piece.baseShape,
      (piece.initialRotation + rotation) % 4,
    );
    final positions = cells.map((c) => [row + c[0], col + c[1]]).toList();
    if (positions.any(
      (p) =>
          p[0] < 0 ||
          p[0] >= 11 ||
          p[1] < 0 ||
          p[1] >= 11 ||
          board[p[0] * 11 + p[1]] != null,
    )) {
      return const PlacementResult(false, 'そこには置けません');
    }
    final firstMove = player.hand.every((p) => !p.used);
    final touchesStart = positions.any(
      (p) => p[1] == 5 && (player.id == 0 ? p[0] == 10 : p[0] == 0),
    );
    if (firstMove && !touchesStart)
      return PlacementResult(false, '${player.name}の最初のブロックは6列目に置いてください');
    if (!firstMove && !_touchesOwnEdge(player.id, positions))
      return const PlacementResult(false, '自分のブロックの辺に接する場所を選んでください');
    return PlacementResult(true, '', positions: positions);
  }

  void skipTurn() {
    skippedTurns++;
    message = '置ける場所がないためスキップ';
    _advance();
  }

  void cpuMove() {
    final player = players[1];
    for (var handIndex = 0; handIndex < player.hand.length; handIndex++) {
      if (player.hand[handIndex].used) continue;
      for (var rotation = 0; rotation < 4; rotation++) {
        for (var row = 0; row < 11; row++) {
          for (var col = 0; col < 11; col++) {
            final result = tryPlace(handIndex, rotation, row, col);
            if (result.success) return;
          }
        }
      }
    }
    skipTurn();
  }

  void _advance() {
    if (players.every((p) => p.hand.every((piece) => piece.used)) ||
        skippedTurns >= 2) {
      finished = true;
      return;
    }
    turn = 1 - turn;
  }

  bool _touchesOwnEdge(int playerId, List<List<int>> positions) =>
      positions.any((p) {
        const directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ];
        return directions.any((d) {
          final row = p[0] + d[0];
          final col = p[1] + d[1];
          return row >= 0 &&
              row < 11 &&
              col >= 0 &&
              col < 11 &&
              board[row * 11 + col] == playerId;
        });
      });

  int _touchingEdges(int playerId, List<List<int>> positions) =>
      positions.fold(0, (total, p) {
        const directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ];
        return total +
            directions.where((d) {
              final row = p[0] + d[0];
              final col = p[1] + d[1];
              return row >= 0 &&
                  row < 11 &&
                  col >= 0 &&
                  col < 11 &&
                  board[row * 11 + col] == playerId;
            }).length;
      });
}

class Player {
  Player(this.id, this.name, this.color, this.hand);

  final int id;
  final String name;
  final Color color;
  final List<HandPiece> hand;
  int score = 0;
  int energy = 2;
}

class HandPiece {
  HandPiece(this.baseShape, this.color, this.initialRotation);

  final List<List<int>> baseShape;
  final Color color;
  final int initialRotation;
  bool used = false;

  List<List<int>> get shape => rotate(baseShape, initialRotation);
}

class PlacementResult {
  const PlacementResult(
    this.success,
    this.message, {
    this.positions = const [],
  });

  final bool success;
  final String message;
  final List<List<int>> positions;
}

List<List<int>> rotate(List<List<int>> source, int turns) {
  var cells = source.map((c) => [...c]).toList();
  for (var i = 0; i < turns % 4; i++) {
    cells = cells.map((c) => [c[1], -c[0]]).toList();
  }
  final minRow = cells.map((c) => c[0]).reduce(min);
  final minCol = cells.map((c) => c[1]).reduce(min);
  return cells.map((c) => [c[0] - minRow, c[1] - minCol]).toList();
}

List<HandPiece> _createHand(Random random) {
  const diceNets = [
    [
      [0, 1],
      [1, 1],
      [2, 1],
      [3, 1],
      [3, 0],
      [3, 2],
    ],
    [
      [0, 1],
      [1, 1],
      [2, 1],
      [3, 1],
      [2, 0],
      [2, 2],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 1],
      [2, 1],
      [3, 1],
      [3, 2],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 1],
      [2, 1],
      [2, 2],
      [3, 2],
    ],
    [
      [0, 1],
      [1, 1],
      [2, 1],
      [3, 1],
      [1, 0],
      [3, 2],
    ],
    [
      [0, 0],
      [1, 0],
      [1, 1],
      [1, 2],
      [2, 2],
      [3, 2],
    ],
    [
      [0, 0],
      [1, 0],
      [2, 0],
      [2, 1],
      [2, 2],
      [3, 2],
    ],
    [
      [0, 2],
      [1, 0],
      [1, 1],
      [1, 2],
      [2, 0],
      [2, 1],
    ],
    [
      [0, 0],
      [0, 1],
      [0, 2],
      [1, 1],
      [2, 1],
      [3, 1],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 1],
      [1, 2],
      [2, 2],
      [3, 2],
    ],
    [
      [0, 1],
      [1, 1],
      [2, 0],
      [2, 1],
      [2, 2],
      [3, 1],
    ],
  ];
  const colors = [
    _gold,
    _blue,
    _red,
    Color(0xff8f7aea),
    Color(0xff62b36f),
    Color(0xffe76f51),
  ];
  final candidates = List<int>.generate(diceNets.length, (index) => index)
    ..shuffle(random);
  final pieces = List.generate(
    6,
    (i) => HandPiece(diceNets[candidates[i]], colors[i], random.nextInt(4)),
  );
  pieces.shuffle(random);
  return pieces;
}
