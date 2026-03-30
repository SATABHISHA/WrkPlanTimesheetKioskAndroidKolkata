import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../constants/app_colors.dart';

/// Punch status screen – shows "You Are In", "You are on Break!" or "Good Bye!"
/// with animated green tick, green-tinted borders, matching PDF page 5 design.
class PunchStatusScreen extends StatefulWidget {
  const PunchStatusScreen({super.key});

  @override
  State<PunchStatusScreen> createState() => _PunchStatusScreenState();
}

class _PunchStatusScreenState extends State<PunchStatusScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tickCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _checkAnim;

  static const _greenTick = Color(0xFF2E7D32); // green-800
  static const _borderGreen = AppColors.secondary; // #81B1AE slight green

  @override
  void initState() {
    super.initState();
    _tickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Circle scales in from 0 → 1 during first 50%
    _scaleAnim = CurvedAnimation(
      parent: _tickCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    // Checkmark draws during 40% → 100%
    _checkAnim = CurvedAnimation(
      parent: _tickCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _tickCtrl.forward();
  }

  @override
  void dispose() {
    _tickCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth       = context.watch<AuthProvider>();
    final isBreak    = auth.punchOutBreak == 'break';
    final isOut      = auth.punchOutBreak == 'out';
    final statusText = auth.checkedInOut.isNotEmpty
        ? auth.checkedInOut
        : (isBreak ? 'You are on Break!' : (isOut ? 'Good Bye!' : 'You Are In'));
    final now        = DateTime.now();
    final dateStr    = DateFormat('MM/dd/yy').format(now);
    final timeStr    = DateFormat('hh:mm a').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // ── Animated green tick ──────────────────────────────────
                  AnimatedBuilder(
                    animation: _tickCtrl,
                    builder: (context, _) {
                      return Transform.scale(
                        scale: _scaleAnim.value,
                        child: SizedBox(
                          width: 90,
                          height: 90,
                          child: CustomPaint(
                            painter: _CheckPainter(
                              progress: _checkAnim.value,
                              circleColor: _greenTick,
                              checkColor: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Status text ──────────────────────────────────────────
                  Text(statusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.2)),
                  const SizedBox(height: 14),

                  // ── Date ─────────────────────────────────────────────────
                  Text(dateStr,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF555555))),
                  const SizedBox(height: 4),

                  // ── Time ─────────────────────────────────────────────────
                  Text(timeStr,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF555555))),

                  const Spacer(flex: 1),

                  // ── Action buttons ───────────────────────────────────────
                  if (!isOut) ...[
                    _outlinedBtn('View / Select / Switch Task',
                        () => Navigator.of(context).pushNamed('/task-selection')),
                    const SizedBox(height: 14),
                    _outlinedBtn('View Leave Balance', () {
                      Navigator.of(context).pushReplacementNamed('/recognition-option');
                    }),
                    const SizedBox(height: 14),
                  ],

                  // ── Logout (bordered) ────────────────────────────────────
                  _outlinedBtn('Logout', () {
                    auth.endSession();
                    Navigator.of(context).pushReplacementNamed('/login');
                  }),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlinedBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textColor,
          side: const BorderSide(color: _borderGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1)),
      ),
    );
  }
}

// ── Animated checkmark painter ─────────────────────────────────────────────────

class _CheckPainter extends CustomPainter {
  final double progress; // 0 → 1
  final Color circleColor;
  final Color checkColor;

  _CheckPainter({
    required this.progress,
    required this.circleColor,
    required this.checkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Green circle
    final circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    // White checkmark (animated draw)
    if (progress > 0) {
      final checkPaint = Paint()
        ..color = checkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.08
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      // Checkmark points relative to size
      final p1 = Offset(size.width * 0.25, size.height * 0.50);
      final p2 = Offset(size.width * 0.43, size.height * 0.67);
      final p3 = Offset(size.width * 0.75, size.height * 0.35);

      path.moveTo(p1.dx, p1.dy);

      if (progress < 0.5) {
        // First leg: p1 → p2
        final t = progress / 0.5;
        final x = p1.dx + (p2.dx - p1.dx) * t;
        final y = p1.dy + (p2.dy - p1.dy) * t;
        path.lineTo(x, y);
      } else {
        // First leg complete
        path.lineTo(p2.dx, p2.dy);
        // Second leg: p2 → p3
        final t = (progress - 0.5) / 0.5;
        final x = p2.dx + (p3.dx - p2.dx) * t;
        final y = p2.dy + (p3.dy - p2.dy) * t;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
