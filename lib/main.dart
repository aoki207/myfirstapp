import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const BlokusApp());

const _navy = Color(0xff101827);
const _panel = Color(0xff182337);
const _grid = Color(0xff25334a);
const _gold = Color(0xfff5a524);
const _blue = Color(0xff56b4d3);
const _red = Color(0xffef6f61);

final playerProfile = PlayerStyleProfile();

Widget _rulesContent() {
  const headingStyle = TextStyle(
    color: _gold,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  const bodyStyle = TextStyle(
    color: Color(0xffc8d1df),
    fontSize: 13,
    height: 1.45,
  );
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('盤面にブロックをつなげて、高得点を目指す対戦ゲーム！', style: bodyStyle),
        const SizedBox(height: 16),
        const Text('1. ターンの流れ', style: headingStyle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _RuleStep(icon: Icons.touch_app_rounded, label: 'ブロックを選ぶ'),
              Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xff71819a),
                size: 17,
              ),
              _RuleStep(icon: Icons.visibility_rounded, label: '影を確認'),
              Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xff71819a),
                size: 17,
              ),
              _RuleStep(icon: Icons.check_circle_rounded, label: 'もう一度タップ'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('💡 ブロックを回転すると、R-Energy⚡を1消費', style: bodyStyle),
        const SizedBox(height: 16),
        const Text('2. 配置のルール', style: headingStyle),
        const SizedBox(height: 6),
        const Text(
          '・自分のブロックと接すること\n・重ね置き不可）\n※置く場所がない場合はスキップ',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        const Text('3. 得点と勝敗', style: headingStyle),
        const SizedBox(height: 6),
        const Text(
          '得点：自分のブロック同士をぴったりくっつけると＋100pt！\n（接している「辺」の数 × 100pt）\n\n終了：手持ちのブロックがなくなる、または2人とも置けなくなったらゲーム終了\n勝利：最終ポイントが高いプレイヤーの勝ち！',
          style: bodyStyle,
        ),
      ],
    ),
  );
}

class _RuleStep extends StatelessWidget {
  const _RuleStep({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _gold, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xffd4ddeb), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _FieldLogo extends StatelessWidget {
  const _FieldLogo({this.size = 82});

  final double size;

  @override
  Widget build(BuildContext context) {
    const cells = [
      null,
      _red,
      _red,
      null,
      null,
      _blue,
      _red,
      _red,
      _red,
      _red,
      _blue,
      _blue,
      null,
      null,
      _red,
      null,
      _blue,
      _blue,
      _blue,
      null,
      null,
      _blue,
      _blue,
      null,
      null,
    ];
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: _grid,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: _gold.withAlpha(180), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _gold.withAlpha(35),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: cells.length,
        itemBuilder: (context, index) {
          final color = cells[index];
          return DecoratedBox(
            decoration: BoxDecoration(
              color: color ?? _navy,
              borderRadius: BorderRadius.circular(2),
              border: color == null
                  ? Border.all(color: const Color(0xff33445f), width: 0.5)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

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
                  const _FieldLogo(),
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
                    'ポイントを稼ぐか。メンタルを削るか。',
                    style: TextStyle(
                      color: Color(0xff9aa8bd),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
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
                  const SizedBox(height: 14),
                  _menuButton(
                    context,
                    'マイページ',
                    Icons.radar_rounded,
                    () => _showProfile(context),
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

  void _showProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
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
        title: const Text('📖 ゲームの遊び方'),
        content: _rulesContent(),
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const axisNames = ['得点志向', '回転活用度', '妨害志向', '終盤決定力', 'ブロック完遂度'];

  @override
  Widget build(BuildContext context) {
    final ratings = playerProfile.ratings;
    return Scaffold(
      appBar: AppBar(title: const Text('マイページ')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              Text(
                'PLAYER 1のプレイスタイル',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '5軸評価',
                style: const TextStyle(color: Color(0xffaebbd0)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 310,
                child: CustomPaint(
                  painter: _RadarPainter(ratings),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 14),
              _profileStats(),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  ),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('プレイ履歴を見る'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xff2e3d56)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statRow('試合数', '${playerProfile.gamesPlayed}試合'),
          const SizedBox(height: 9),
          _statRow(
            '勝敗',
            '${playerProfile.wins}勝 ${playerProfile.losses}敗 ${playerProfile.draws}分',
          ),
          const SizedBox(height: 9),
          _statRow('平均ポイント', '${playerProfile.averageScore} pt'),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xffaebbd0))),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = playerProfile.matches;
    return Scaffold(
      appBar: AppBar(title: const Text('プレイ履歴')),
      body: matches.isEmpty
          ? const Center(child: Text('まだプレイ履歴がありません'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final match = matches[index];
                return ListTile(
                  tileColor: _panel,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    '${match.playerOneName}  vs  ${match.playerTwoName}',
                  ),
                  subtitle: Text(
                    'プレイ開始: ${match.formattedStartedAt}\n'
                    '勝者: ${match.winnerName}  ・  先攻: ${match.firstPlayerName}  ・  後攻: ${match.secondPlayerName}\n'
                    '${match.playerOneScore} pt  -  ${match.playerTwoScore} pt  ・  '
                    'プレイ時間: ${match.formattedDuration}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchLogPage(match: match),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MatchLogPage extends StatefulWidget {
  const MatchLogPage({super.key, required this.match});

  final MatchRecord match;

  @override
  State<MatchLogPage> createState() => _MatchLogPageState();
}

class _MatchLogPageState extends State<MatchLogPage> {
  int? _selectedLog;

  @override
  Widget build(BuildContext context) {
    final board = _selectedLog == null
        ? widget.match.initialBoard
        : widget.match.logs[_selectedLog!].board;
    final playerOneScore = _selectedLog == null
        ? 0
        : widget.match.logs[_selectedLog!].playerOneTotalPoints;
    final playerTwoScore = _selectedLog == null
        ? 0
        : widget.match.logs[_selectedLog!].playerTwoTotalPoints;
    return Scaffold(
      appBar: AppBar(title: const Text('試合ログ')),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Center(
                  child: _HistoryBoard(
                    board: board,
                    playerOneName: widget.match.playerOneName,
                    playerTwoName: widget.match.playerTwoName,
                    playerOneScore: playerOneScore,
                    playerTwoScore: playerTwoScore,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: widget.match.logs.length,
                itemBuilder: (context, index) {
                  final log = widget.match.logs[index];
                  final selected = index == _selectedLog;
                  final playerColor = log.playerId == 0 ? _blue : _red;
                  return Card(
                    color: selected
                        ? playerColor.withAlpha(75)
                        : playerColor.withAlpha(28),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: playerColor.withAlpha(170)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      selected: selected,
                      title: Text(
                        '${log.turnNumber}ターン目  ${log.playerName}',
                        style: TextStyle(
                          color: playerColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '総得点: ${log.totalPoints} pt  ・  得点: +${log.points} pt  ・  逆転: ${log.comeback ? 'あり' : 'なし'}\n'
                        '妨害度: ${log.obstruction}  ・  回転: ${log.rotated ? 'あり' : 'なし'}',
                      ),
                      onTap: () => setState(() => _selectedLog = index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryBoard extends StatelessWidget {
  const _HistoryBoard({
    required this.board,
    required this.playerOneName,
    required this.playerTwoName,
    required this.playerOneScore,
    required this.playerTwoScore,
  });

  final List<int?> board;
  final String playerOneName;
  final String playerTwoName;
  final int playerOneScore;
  final int playerTwoScore;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = min(
          constraints.maxWidth,
          max(0.0, constraints.maxHeight - 32.0),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$playerOneName  $playerOneScore pt',
                    style: const TextStyle(
                      color: _blue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '$playerTwoName  $playerTwoScore pt',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: _red,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox.square(
              dimension: boardSize,
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
                  itemCount: board.length,
                  itemBuilder: (context, index) {
                    final player = board[index];
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: player == null
                            ? _navy
                            : player == 0
                            ? _blue
                            : _red,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.ratings);

  final List<int> ratings;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.34;
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xff34445f);
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _gold.withAlpha(85);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _gold;

    for (var level = 1; level <= 5; level++) {
      canvas.drawPath(_polygon(center, radius * level / 5), gridPaint);
    }
    for (var index = 0; index < 5; index++) {
      final point = _point(center, radius, index, 5);
      canvas.drawLine(center, point, gridPaint);
    }
    final values = _polygon(
      center,
      radius,
      ratings.map((rating) => rating / 5).toList(),
    );
    canvas.drawPath(values, fillPaint);
    canvas.drawPath(values, linePaint);
    for (var index = 0; index < ProfilePage.axisNames.length; index++) {
      final labelPoint = _point(center, radius + 25, index, 5);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${ProfilePage.axisNames[index]}\n${ratings[index]} / 5',
          style: const TextStyle(
            color: Color(0xffd4ddeb),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 110);
      textPainter.paint(
        canvas,
        Offset(
          labelPoint.dx - textPainter.width / 2,
          labelPoint.dy - textPainter.height / 2,
        ),
      );
    }
  }

  Path _polygon(Offset center, double radius, [List<double>? scales]) {
    final path = Path();
    for (var index = 0; index < 5; index++) {
      final point = _point(
        center,
        radius,
        index,
        5,
        scales == null ? 1 : scales[index],
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  Offset _point(
    Offset center,
    double radius,
    int index,
    int count, [
    double scale = 1,
  ]) {
    final angle = -pi / 2 + 2 * pi * index / count;
    return Offset(
      center.dx + cos(angle) * radius * scale,
      center.dy + sin(angle) * radius * scale,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.ratings != ratings;
}

class MatchPage extends StatefulWidget {
  const MatchPage({super.key, required this.isCpu});

  final bool isCpu;

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage>
    with SingleTickerProviderStateMixin {
  late MatchState _match;
  int _selectedPiece = 0;
  int _rotation = 0;
  int? _previewRow;
  int? _previewCol;
  List<ScoringEdge> _effectEdges = const [];
  int _visibleEffectCells = 0;
  Timer? _effectTimer;
  late final AnimationController _energyBlinkController;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _energyBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      lowerBound: 0.25,
      upperBound: 1,
      value: 1,
    );
    _match = MatchState(widget.isCpu, Random());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nextTurn();
    });
  }

  @override
  void dispose() {
    _effectTimer?.cancel();
    _energyBlinkController.dispose();
    super.dispose();
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
    _energyBlinkController
      ..stop()
      ..value = 1;
  }

  void _rotate() {
    if (_busy) return;
    if (_currentPlayer.energy == 0) {
      setState(() => _match.message = 'エネルギーが0なので回転できません');
      return;
    }
    _energyBlinkController.repeat(reverse: true);
    setState(() {
      _rotation = (_rotation + 1) % 4;
      _clearPreview();
      _match.message = '向きを変えました。置きたいマスをタップ';
    });
  }

  void _place(int row, int col) {
    if (_busy || _match.finished) return;
    final origin = _placementOrigin(row, col);
    if (_previewRow == row && _previewCol == col) {
      final result = _match.tryPlace(
        _selectedPiece,
        _rotation,
        origin[0],
        origin[1],
      );
      if (!result.success) {
        setState(() => _match.message = result.message);
        return;
      }
      setState(() {
        _clearPreview();
        _rotation = 0;
        _selectedPiece = 0;
      });
      _energyBlinkController
        ..stop()
        ..value = 1;
      _startPointEffect(result);
      _nextTurn();
      return;
    }
    final preview = _match.previewPlacement(
      _selectedPiece,
      _rotation,
      origin[0],
      origin[1],
    );
    if (!preview.success) {
      setState(() {
        _previewRow = row;
        _previewCol = col;
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

  List<int> _placementOrigin(int row, int col) {
    final piece = _currentPlayer.hand[_selectedPiece];
    final cells = rotate(
      piece.baseShape,
      (piece.initialRotation + _rotation) % 4,
    );
    final minRow = cells.map((cell) => cell[0]).reduce(min);
    final maxRow = cells.map((cell) => cell[0]).reduce(max);
    final minCol = cells.map((cell) => cell[1]).reduce(min);
    final maxCol = cells.map((cell) => cell[1]).reduce(max);
    return [row - ((minRow + maxRow) ~/ 2), col - ((minCol + maxCol) ~/ 2)];
  }

  void _startPointEffect(PlacementResult result) {
    _effectTimer?.cancel();
    if (result.scoringEdges.isEmpty) return;
    final previousCount = _effectEdges.length;
    final totalCount = previousCount + result.scoringEdges.length;
    setState(() {
      _effectEdges = [..._effectEdges, ...result.scoringEdges];
      _visibleEffectCells = previousCount;
    });
    var index = previousCount;
    _effectTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (index >= totalCount) {
        timer.cancel();
        return;
      }
      setState(() {
        _visibleEffectCells = index + 1;
      });
      index++;
    });
  }

  void _clearPreview() {
    _previewRow = null;
    _previewCol = null;
  }

  bool _isPreviewCell(int row, int col) {
    if (_previewRow == null || _previewCol == null) return false;
    final origin = _placementOrigin(_previewRow!, _previewCol!);
    final preview = _match.previewPlacement(
      _selectedPiece,
      _rotation,
      origin[0],
      origin[1],
    );
    return preview.positions.any(
      (position) => position[0] == row && position[1] == col,
    );
  }

  bool _isOverlappingPreviewCell(int row, int col) {
    if (_previewRow == null || _previewCol == null) return false;
    final origin = _placementOrigin(_previewRow!, _previewCol!);
    final preview = _match.previewPlacement(
      _selectedPiece,
      _rotation,
      origin[0],
      origin[1],
    );
    return preview.conflictingPositions.any(
      (position) => position[0] == row && position[1] == col,
    );
  }

  bool _isOutOfBoundsPreview() {
    if (_previewRow == null || _previewCol == null) return false;
    final origin = _placementOrigin(_previewRow!, _previewCol!);
    return _match
        .previewPlacement(_selectedPiece, _rotation, origin[0], origin[1])
        .outOfBounds;
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
        final result = _match.cpuMove();
        if (result != null) _startPointEffect(result);
        setState(() => _busy = false);
        if (_match.finished) {
          _showResult();
        }
      });
    }
  }

  void _showResult() {
    if (!mounted) return;
    playerProfile.record(_match.players[0], _match.players[1], _match);
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
              _energyIcons(player),
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

  Widget _energyIcons(Player player) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(2, (index) {
        final available = index < player.energy;
        final blinking =
            player.id == _match.turn &&
            _rotation != 0 &&
            index == player.energy - 1;
        final icon = Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Icon(
            Icons.bolt_rounded,
            color: _gold,
            size: 18,
            fill: !available ? 0.2 : 1,
          ),
        );
        return blinking
            ? FadeTransition(opacity: _energyBlinkController, child: icon)
            : Opacity(opacity: available ? 1 : 0.2, child: icon);
      }),
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
            : Center(
                child: _preview(piece, rotation: selected ? _rotation : 0),
              ),
      ),
    );
  }

  Widget _preview(HandPiece piece, {int rotation = 0}) {
    final shape = rotate(
      piece.baseShape,
      (piece.initialRotation + rotation) % 4,
    );
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
              ? 'CPUが考えています...'
              : '${_currentPlayer.name}のターン - ${_match.message}',
          style: const TextStyle(color: Color(0xffc7d0df), fontSize: 12),
        ),
      ),
    ],
  );

  Border? _effectBorder(int row, int col) {
    final edges = _effectEdges
        .take(_visibleEffectCells)
        .where((edge) => edge.row == row && edge.col == col)
        .toList();
    if (edges.isEmpty) return null;
    final sides = edges.map((edge) => edge.side).toSet();
    final glow = BorderSide(color: _gold, width: 2);
    return Border(
      top: sides.contains(EdgeSide.top) ? glow : BorderSide.none,
      right: sides.contains(EdgeSide.right) ? glow : BorderSide.none,
      bottom: sides.contains(EdgeSide.bottom) ? glow : BorderSide.none,
      left: sides.contains(EdgeSide.left) ? glow : BorderSide.none,
    );
  }

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
          final row = index ~/ 11;
          final col = index % 11;
          final effectBorder = _effectBorder(row, col);
          return GestureDetector(
            onTap: () => _place(row, col),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              decoration: BoxDecoration(
                color: _isPreviewCell(row, col)
                    ? (_isOutOfBoundsPreview() ||
                              _isOverlappingPreviewCell(row, col)
                          ? const Color(0xffff8a3d)
                          : _currentPlayer.color.withAlpha(125))
                    : (cell == null ? _navy : _match.players[cell].color),
                border: effectBorder,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: _isPreviewCell(row, col)
                        ? Icon(
                            Icons.circle,
                            size: 5,
                            color:
                                _isOutOfBoundsPreview() ||
                                    _isOverlappingPreviewCell(row, col)
                                ? const Color(0xffffeadb)
                                : const Color(0x80ffffff),
                          )
                        : (cell == null
                              ? null
                              : const Icon(
                                  Icons.circle,
                                  size: 5,
                                  color: Color(0x40000000),
                                )),
                  ),
                ],
              ),
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
      title: const Text('📖 ゲームの遊び方'),
      content: _rulesContent(),
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
    board[10 * 11 + 5] = 0;
    board[5] = 1;
    firstPlayerId = random.nextInt(2);
    turn = firstPlayerId;
    initialBoard = List<int?>.from(board);
  }

  final bool isCpu;
  final Random random;
  final DateTime startedAt = DateTime.now();
  final List<int?> board = List<int?>.filled(121, null);
  late final List<int?> initialBoard;
  late final int firstPlayerId;
  late final List<Player> players;
  final List<TurnLog> turnLogs = [];
  int turn = 0;
  int turnNumber = 0;
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
    final opponentId = 1 - player.id;
    final opponentScoreBefore = players[opponentId].score;
    final playerWasBehind = player.score < opponentScoreBefore;
    final opponentMovesBefore = _countLegalPlacements(opponentId);
    final scoringEdges = _touchingEdges(player.id, positions);
    final touchingEdges = scoringEdges.length;
    for (final p in positions) board[p[0] * 11 + p[1]] = player.id;
    piece.used = true;
    player.score += touchingEdges * 100;
    if (rotated) player.energy--;
    player.placements++;
    player.totalPlacementPoints += touchingEdges * 100;
    player.rotatedPlacements += rotated ? 1 : 0;
    player.lastPlacementPoints = touchingEdges * 100;
    player.obstructionPoints += max(
      0,
      opponentMovesBefore - _countLegalPlacements(opponentId),
    );
    turnNumber++;
    turnLogs.add(
      TurnLog(
        turnNumber: turnNumber,
        playerId: player.id,
        playerName: player.name,
        blockSize: piece.baseShape.length,
        points: touchingEdges * 100,
        totalPoints: player.score,
        playerOneTotalPoints: players[0].score,
        playerTwoTotalPoints: players[1].score,
        comeback: playerWasBehind && player.score > opponentScoreBefore,
        rotated: rotated,
        obstruction: max(
          0,
          opponentMovesBefore - _countLegalPlacements(opponentId),
        ),
        board: List<int?>.from(board),
      ),
    );
    message = '${piece.baseShape.length}マス配置  +${touchingEdges * 100} pt';
    skippedTurns = 0;
    _advance();
    return PlacementResult(
      true,
      '',
      scoringEdges: scoringEdges,
      points: touchingEdges * 100,
    );
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
    final cells = rotate(
      piece.baseShape,
      (piece.initialRotation + rotation) % 4,
    );
    final positions = cells.map((c) => [row + c[0], col + c[1]]).toList();
    final outOfBounds = positions.any(
      (p) => p[0] < 0 || p[0] >= 11 || p[1] < 0 || p[1] >= 11,
    );
    final conflictingPositions = positions.where((p) {
      return outOfBounds || board[p[0] * 11 + p[1]] != null;
    }).toList();
    if (conflictingPositions.isNotEmpty) {
      return PlacementResult(
        false,
        '配置できません',
        positions: positions,
        conflictingPositions: conflictingPositions,
        outOfBounds: outOfBounds,
      );
    }
    if (player.energy == 0) {
      if (rotation != 0) {
        return PlacementResult(
          false,
          'エネルギーが0なので回転できません',
          positions: positions,
          outOfBounds: outOfBounds,
        );
      }
    }
    if (!_touchesOwnEdge(player.id, positions))
      return PlacementResult(
        false,
        '自分のブロックの辺に接する場所を選んでください',
        positions: positions,
        outOfBounds: outOfBounds,
      );
    return PlacementResult(true, '', positions: positions);
  }

  void skipTurn() {
    skippedTurns++;
    message = '置ける場所がないためスキップ';
    _advance();
  }

  PlacementResult? cpuMove() {
    final player = players[1];
    for (var handIndex = 0; handIndex < player.hand.length; handIndex++) {
      if (player.hand[handIndex].used) continue;
      for (var rotation = 0; rotation < 4; rotation++) {
        for (var row = 0; row < 11; row++) {
          for (var col = 0; col < 11; col++) {
            final result = tryPlace(handIndex, rotation, row, col);
            if (result.success) return result;
          }
        }
      }
    }
    skipTurn();
    return null;
  }

  void _advance() {
    if (players.every((p) => p.hand.every((piece) => piece.used))) {
      finished = true;
      return;
    }
    turn = 1 - turn;
    while (players[turn].hand.every((piece) => piece.used)) {
      skippedTurns++;
      message = '${players[turn].name}は手札を置ききったため自動スキップ';
      if (skippedTurns >= 2) {
        finished = true;
        return;
      }
      turn = 1 - turn;
    }
    if (skippedTurns >= 2) finished = true;
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

  List<ScoringEdge> _touchingEdges(int playerId, List<List<int>> positions) =>
      positions.expand((p) {
        const directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ];
        return directions
            .where((d) {
              final row = p[0] + d[0];
              final col = p[1] + d[1];
              return row >= 0 &&
                  row < 11 &&
                  col >= 0 &&
                  col < 11 &&
                  board[row * 11 + col] == playerId;
            })
            .map((d) => ScoringEdge(p[0], p[1], _edgeSide(d[0], d[1])));
      }).toList();

  EdgeSide _edgeSide(int rowDelta, int colDelta) {
    if (rowDelta < 0) return EdgeSide.top;
    if (rowDelta > 0) return EdgeSide.bottom;
    if (colDelta < 0) return EdgeSide.left;
    return EdgeSide.right;
  }

  int _countLegalPlacements(int playerId) {
    final player = players[playerId];
    var count = 0;
    for (var handIndex = 0; handIndex < player.hand.length; handIndex++) {
      final piece = player.hand[handIndex];
      if (piece.used) continue;
      for (var rotation = 0; rotation < 4; rotation++) {
        if (rotation != 0 && player.energy == 0) continue;
        final cells = rotate(
          piece.baseShape,
          (piece.initialRotation + rotation) % 4,
        );
        for (var row = 0; row < 11; row++) {
          for (var col = 0; col < 11; col++) {
            final positions = cells
                .map((cell) => [row + cell[0], col + cell[1]])
                .toList();
            if (positions.any(
              (position) =>
                  position[0] < 0 ||
                  position[0] >= 11 ||
                  position[1] < 0 ||
                  position[1] >= 11 ||
                  board[position[0] * 11 + position[1]] != null,
            )) {
              continue;
            }
            if (_touchesOwnEdge(playerId, positions)) count++;
          }
        }
      }
    }
    return count;
  }
}

class Player {
  Player(this.id, this.name, this.color, this.hand);

  final int id;
  final String name;
  final Color color;
  final List<HandPiece> hand;
  int score = 0;
  int energy = 2;
  int placements = 0;
  int rotatedPlacements = 0;
  int totalPlacementPoints = 0;
  int lastPlacementPoints = 0;
  int obstructionPoints = 0;
}

class PlayerStyleProfile {
  final List<List<double>> _history = [];
  final List<MatchRecord> _matches = [];
  int wins = 0;
  int losses = 0;
  int draws = 0;
  int _totalScore = 0;

  int get gamesPlayed => _history.length;

  List<MatchRecord> get matches => List.unmodifiable(_matches);

  int get averageScore =>
      gamesPlayed == 0 ? 0 : (_totalScore / gamesPlayed).round();

  List<int> get ratings {
    if (_history.isEmpty) return List.filled(5, 3);
    return List.generate(5, (axis) {
      final average =
          _history.map((game) => game[axis]).reduce((a, b) => a + b) /
          _history.length;
      return average.round().clamp(1, 5);
    });
  }

  void record(Player player, Player opponent, MatchState match) {
    _totalScore += player.score;
    if (player.score > opponent.score) {
      wins++;
    } else if (player.score < opponent.score) {
      losses++;
    } else {
      draws++;
    }
    final placements = max(1, player.placements);
    final completion =
        player.hand.where((piece) => piece.used).length / player.hand.length;
    _history.add([
      _rating(1 + min(4, player.totalPlacementPoints / placements / 100)),
      _rating(1 + player.rotatedPlacements / placements * 4),
      _rating(1 + min(4, player.obstructionPoints / placements / 20)),
      _rating(1 + min(4, player.lastPlacementPoints / 100)),
      _rating(1 + completion * 4),
    ]);
    _matches.insert(0, MatchRecord.fromMatch(match));
  }

  double _rating(double value) => value.clamp(1, 5);
}

class MatchRecord {
  MatchRecord({
    required this.playerOneName,
    required this.playerTwoName,
    required this.winnerName,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.startedAt,
    required this.duration,
    required this.initialBoard,
    required this.logs,
  });

  factory MatchRecord.fromMatch(MatchState match) {
    final playerOne = match.players[0];
    final playerTwo = match.players[1];
    final winnerName = playerOne.score == playerTwo.score
        ? '引き分け'
        : playerOne.score > playerTwo.score
        ? playerOne.name
        : playerTwo.name;
    return MatchRecord(
      playerOneName: playerOne.name,
      playerTwoName: playerTwo.name,
      winnerName: winnerName,
      firstPlayerName: match.players[match.firstPlayerId].name,
      secondPlayerName: match.players[1 - match.firstPlayerId].name,
      playerOneScore: playerOne.score,
      playerTwoScore: playerTwo.score,
      startedAt: match.startedAt,
      duration: DateTime.now().difference(match.startedAt),
      initialBoard: List<int?>.from(match.initialBoard),
      logs: List.unmodifiable(match.turnLogs),
    );
  }

  final String playerOneName;
  final String playerTwoName;
  final String winnerName;
  final String firstPlayerName;
  final String secondPlayerName;
  final int playerOneScore;
  final int playerTwoScore;
  final DateTime startedAt;
  final Duration duration;
  final List<int?> initialBoard;
  final List<TurnLog> logs;

  String get formattedStartedAt {
    final month = startedAt.month.toString().padLeft(2, '0');
    final day = startedAt.day.toString().padLeft(2, '0');
    final hour = startedAt.hour.toString().padLeft(2, '0');
    final minute = startedAt.minute.toString().padLeft(2, '0');
    return '${startedAt.year}/$month/$day $hour:$minute';
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class TurnLog {
  const TurnLog({
    required this.turnNumber,
    required this.playerId,
    required this.playerName,
    required this.blockSize,
    required this.points,
    required this.totalPoints,
    required this.playerOneTotalPoints,
    required this.playerTwoTotalPoints,
    required this.comeback,
    required this.rotated,
    required this.obstruction,
    required this.board,
  });

  final int turnNumber;
  final int playerId;
  final String playerName;
  final int blockSize;
  final int points;
  final int totalPoints;
  final int playerOneTotalPoints;
  final int playerTwoTotalPoints;
  final bool comeback;
  final bool rotated;
  final int obstruction;
  final List<int?> board;
}

class HandPiece {
  HandPiece(this.baseShape, this.color, this.initialRotation);

  final List<List<int>> baseShape;
  final Color color;
  final int initialRotation;
  bool used = false;

  List<List<int>> get shape => rotate(baseShape, initialRotation);
}

enum EdgeSide { top, right, bottom, left }

class ScoringEdge {
  const ScoringEdge(this.row, this.col, this.side);

  final int row;
  final int col;
  final EdgeSide side;
}

class PlacementResult {
  const PlacementResult(
    this.success,
    this.message, {
    this.positions = const [],
    this.conflictingPositions = const [],
    this.outOfBounds = false,
    this.scoringEdges = const [],
    this.points = 0,
  });

  final bool success;
  final String message;
  final List<List<int>> positions;
  final List<List<int>> conflictingPositions;
  final bool outOfBounds;
  final List<ScoringEdge> scoringEdges;
  final int points;
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
      [0, 2],
      [1, 2],
      [1, 3],
      [1, 4],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 1],
      [1, 2],
      [1, 3],
      [2, 1],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 1],
      [1, 2],
      [1, 3],
      [2, 2],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 1],
      [1, 2],
      [1, 3],
      [2, 3],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 1],
      [1, 2],
      [2, 1],
      [3, 1],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 1],
      [1, 2],
      [2, 2],
      [2, 3],
    ],
    [
      [0, 0],
      [0, 1],
      [1, 1],
      [2, 1],
      [2, 2],
      [3, 1],
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
      [0, 1],
      [1, 0],
      [1, 1],
      [1, 2],
      [1, 3],
      [2, 1],
    ],
    [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, 2],
      [1, 3],
      [2, 2],
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
