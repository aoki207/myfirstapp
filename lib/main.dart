import 'package:flutter/material.dart';

void main() => runApp(const BlokusApp());

class BlokusApp extends StatelessWidget {
  const BlokusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ブロックス',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff101827),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xfff5a524),
          brightness: Brightness.dark,
        ),
      ),
      home: const BlokusPage(),
    );
  }
}

class BlokusPage extends StatefulWidget {
  const BlokusPage({super.key});

  @override
  State<BlokusPage> createState() => _BlokusPageState();
}

class _BlokusPageState extends State<BlokusPage> {
  static const boardSize = 10;
  final List<Color?> _board = List<Color?>.filled(boardSize * boardSize, null);
  final List<Piece> _pieces = const [
    Piece([
      [0, 0],
    ], Color(0xfff5a524)),
    Piece([
      [0, 0],
      [0, 1],
    ], Color(0xffef6f61)),
    Piece([
      [0, 0],
      [1, 0],
      [1, 1],
    ], Color(0xff5bc0be)),
    Piece([
      [0, 0],
      [0, 1],
      [0, 2],
    ], Color(0xff8f7aea)),
    Piece([
      [0, 0],
      [0, 1],
      [1, 0],
      [1, 1],
    ], Color(0xffe76f51)),
    Piece([
      [0, 1],
      [1, 0],
      [1, 1],
      [1, 2],
    ], Color(0xff62b36f)),
  ];
  int _selectedPiece = 0;
  int _rotation = 0;
  int _score = 0;
  String _message = 'ピースを選んで盤面に置こう';

  Piece get _currentPiece => _pieces[_selectedPiece];

  List<List<int>> get _rotatedShape {
    var cells = _currentPiece.cells.map((cell) => [...cell]).toList();
    for (var turn = 0; turn < _rotation; turn++) {
      cells = cells.map((cell) => [cell[1], -cell[0]]).toList();
    }
    final minRow = cells.map((cell) => cell[0]).reduce((a, b) => a < b ? a : b);
    final minCol = cells.map((cell) => cell[1]).reduce((a, b) => a < b ? a : b);
    return cells.map((cell) => [cell[0] - minRow, cell[1] - minCol]).toList();
  }

  void _selectPiece(int index) => setState(() {
    _selectedPiece = index;
    _rotation = 0;
    _message = '置きたい場所をタップ';
  });

  void _rotate() => setState(() {
    _rotation = (_rotation + 1) % 4;
    _message = '回転しました。置きたい場所をタップ';
  });

  void _placePiece(int row, int col) {
    final positions = _rotatedShape
        .map((cell) => [row + cell[0], col + cell[1]])
        .toList();
    final canPlace = positions.every((position) {
      final targetRow = position[0];
      final targetCol = position[1];
      return targetRow >= 0 &&
          targetRow < boardSize &&
          targetCol >= 0 &&
          targetCol < boardSize &&
          _board[targetRow * boardSize + targetCol] == null;
    });
    if (!canPlace) {
      setState(() => _message = 'そこには置けません。別の場所を選んでね');
      return;
    }
    setState(() {
      for (final position in positions) {
        _board[position[0] * boardSize + position[1]] = _currentPiece.color;
      }
      _score += positions.length * 10;
      _message = 'ナイス！ 次のピースを選ぼう';
    });
  }

  void _reset() => setState(() {
    for (var index = 0; index < _board.length; index++) {
      _board[index] = null;
    }
    _score = 0;
    _selectedPiece = 0;
    _rotation = 0;
    _message = 'ピースを選んで盤面に置こう';
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 46,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildScoreBar(),
                  const SizedBox(height: 20),
                  _buildBoard(),
                  const SizedBox(height: 16),
                  _buildMessage(),
                  const SizedBox(height: 18),
                  _buildPieceTray(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xfff5a524),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.grid_4x4_rounded,
          color: Color(0xff101827),
          size: 25,
        ),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BLOKUS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            Text(
              'ひらめきで、つなぐ。',
              style: TextStyle(color: Color(0xff8d9ab0), fontSize: 12),
            ),
          ],
        ),
      ),
      IconButton(
        onPressed: _reset,
        tooltip: 'リセット',
        icon: const Icon(Icons.refresh_rounded),
      ),
    ],
  );

  Widget _buildScoreBar() => Row(
    children: [
      Expanded(
        child: _stat(
          'SCORE',
          '$_score',
          Icons.stars_rounded,
          const Color(0xfff5a524),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _stat(
          'CELLS',
          '${_board.where((cell) => cell != null).length}/100',
          Icons.apps_rounded,
          const Color(0xff5bc0be),
        ),
      ),
    ],
  );

  Widget _stat(String label, String value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xff182337),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xff8d9ab0),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildBoard() => AspectRatio(
    aspectRatio: 1,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xff25334a),
        borderRadius: BorderRadius.circular(18),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: boardSize,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: _board.length,
        itemBuilder: (context, index) {
          final color = _board[index];
          return GestureDetector(
            onTap: () => _placePiece(index ~/ boardSize, index % boardSize),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: color ?? const Color(0xff182337),
                borderRadius: BorderRadius.circular(4),
              ),
              child: color == null
                  ? null
                  : const Icon(Icons.circle, size: 7, color: Color(0x33000000)),
            ),
          );
        },
      ),
    ),
  );

  Widget _buildMessage() => Row(
    children: [
      const Icon(Icons.touch_app_rounded, color: Color(0xfff5a524), size: 19),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          _message,
          style: const TextStyle(color: Color(0xffc5cedc), fontSize: 13),
        ),
      ),
      IconButton(
        onPressed: _rotate,
        tooltip: '回転',
        icon: const Icon(Icons.rotate_right_rounded, color: Color(0xfff5a524)),
      ),
    ],
  );

  Widget _buildPieceTray() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'PIECES',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xff8d9ab0),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_pieces.length, _pieceButton),
      ),
    ],
  );

  Widget _pieceButton(int index) {
    final piece = _pieces[index];
    final selected = index == _selectedPiece;
    return GestureDetector(
      onTap: () => _selectPiece(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 49,
        height: 58,
        decoration: BoxDecoration(
          color: selected ? const Color(0xff273852) : const Color(0xff182337),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? piece.color : const Color(0xff27334a),
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(child: _piecePreview(piece)),
      ),
    );
  }

  Widget _piecePreview(Piece piece) {
    final maxRow = piece.cells
        .map((cell) => cell[0])
        .reduce((a, b) => a > b ? a : b);
    final maxCol = piece.cells
        .map((cell) => cell[1])
        .reduce((a, b) => a > b ? a : b);
    return SizedBox(
      width: (maxCol + 1) * 9.0,
      height: (maxRow + 1) * 9.0,
      child: Stack(
        children: piece.cells
            .map(
              (cell) => Positioned(
                left: cell[1] * 9,
                top: cell[0] * 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: piece.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class Piece {
  const Piece(this.cells, this.color);

  final List<List<int>> cells;
  final Color color;
}
