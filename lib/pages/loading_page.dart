import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  // ─── Brand colours ───────────────────────────────────────────────────────────
  static const Color bg     = Color(0xFFF4F0E6);
  static const Color yellow = Color(0xFFFDE047);
  static const Color pink   = Color(0xFFF9A8D4);
  static const Color blue   = Color(0xFF93C5FD);
  static const Color green  = Color(0xFF86EFAC);
  static const Color orange = Color(0xFFFDBA74);

  // Progress bar fills over 2.4 s, then we navigate.
  static const Duration _totalDuration = Duration(milliseconds: 2400);

  late final AnimationController _progressCtrl;
  late final Animation<double>   _progressAnim;

  // Three bouncing dots staggered by 200 ms each.
  late final AnimationController _dotCtrl;
  late final List<Animation<double>> _dotAnims;

  // Colour cycle for the progress bar fill.
  final List<Color> _barColors = [yellow, pink, green, blue, orange];
  int _barColorIdx = 0;

  @override
  void initState() {
    super.initState();

    // ── Progress bar ──────────────────────────────────────────────────────────
    _progressCtrl = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );
    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOut,
    );

    // Cycle bar colour every 500 ms while loading.
    _progressCtrl.addListener(() {
      final newIdx = (_progressCtrl.value * (_barColors.length - 1)).floor();
      if (newIdx != _barColorIdx) {
        setState(() => _barColorIdx = newIdx);
      }
    });

    _progressCtrl.forward().then((_) {
      if (mounted) context.go('/home-page');
    });

    // ── Bouncing dots ─────────────────────────────────────────────────────────
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dotAnims = List.generate(3, (i) {
      final start = i * 0.2;
      return Tween<double>(begin: 0, end: -14).animate(
        CurvedAnimation(
          parent: _dotCtrl,
          curve: Interval(start, min(start + 0.5, 1.0), curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top badge ──────────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: yellow,
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                  ],
                ),
                child: const Text(
                  'LOADING',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),

              const Spacer(),

              // ── Headline ───────────────────────────────────────────────────
              const Text(
                'GETTING\nYOUR\nWALLS.',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 0.88,
                  letterSpacing: -2,
                ),
              ),

              const SizedBox(height: 40),

              // ── Progress bar ───────────────────────────────────────────────
              _BrutalProgressBar(
                progress: _progressAnim,
                fillColor: _barColors[_barColorIdx],
              ),

              const SizedBox(height: 32),

              // ── Status row ─────────────────────────────────────────────────
              Row(
                children: [
                  // Bouncing dots
                  AnimatedBuilder(
                    animation: _dotCtrl,
                    builder: (_, __) => Row(
                      children: List.generate(3, (i) {
                        return Transform.translate(
                          offset: Offset(0, _dotAnims[i].value),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _barColors[_barColorIdx],
                              border:
                                  Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(width: 12),

                  AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) => Text(
                      _statusLabel(_progressAnim.value),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Percentage counter
                  AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        '${(_progressAnim.value * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Decorative colour chips ────────────────────────────────────
              Row(
                children: [
                  _ColorChip(color: yellow),
                  _ColorChip(color: pink),
                  _ColorChip(color: green),
                  _ColorChip(color: blue),
                  _ColorChip(color: orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(double v) {
    if (v < 0.30) return 'INITIALISING...';
    if (v < 0.60) return 'FETCHING WALLS...';
    if (v < 0.85) return 'ALMOST READY...';
    return 'LAUNCHING!';
  }
}

// ─── Progress bar widget ─────────────────────────────────────────────────────

class _BrutalProgressBar extends StatelessWidget {
  const _BrutalProgressBar({
    required this.progress,
    required this.fillColor,
  });

  final Animation<double> progress;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(6, 6)),
        ],
      ),
      child: AnimatedBuilder(
        animation: progress,
        builder: (_, __) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: fillColor,
          ),
        ),
      ),
    );
  }
}

// ─── Small colour square ─────────────────────────────────────────────────────

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3)),
        ],
      ),
    );
  }
}
