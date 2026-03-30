import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../models/task_model.dart';
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
                    _outlinedBtn('View Leave Balance', () => _showLeaveBalance(context)),
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

  // ── Leave balance API call + dialog ────────────────────────────────────────

  void _showLeaveBalance(BuildContext ctx) async {
    final auth = ctx.read<AuthProvider>();
    final api  = ApiService();

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final json = await api.getLeaveBalance(
        corpId: auth.user!.corpID!,
        employeeId: auth.user!.personId!,
      );
      if (!mounted) return;
      Navigator.of(ctx).pop(); // dismiss loading

      final status = (json['status'] ?? json['Status'] ?? '').toString().toLowerCase();
      if (status == 'true') {
        final raw = json['LeaveBalanceItems'] ?? json['leavebalancedata'];
        final items = <LeaveBalanceItem>[];

        if (raw is Map) {
          for (final entry in raw.entries) {
            items.add(LeaveBalanceItem.fromEntry(entry.key.toString(), entry.value));
          }
        } else if (raw is List) {
          for (final e in raw) {
            if (e is Map) {
              items.add(LeaveBalanceItem.fromJson(Map<String, dynamic>.from(e)));
            }
          }
        }

        if (items.isEmpty) {
          _showSnack(ctx, 'No leave balance data found');
          return;
        }

        _showLeaveDialog(ctx, items,
          dateUpto: json['LeaveDateUpto']?.toString() ?? '',
          employeeName: auth.user?.empName ?? auth.user?.userName ?? '',
        );
      } else {
        _showSnack(ctx, json['message']?.toString() ?? 'No data');
      }
    } catch (_) {
      if (mounted) Navigator.of(ctx).pop();
      _showSnack(ctx, 'Could not connect to server');
    }
  }

  void _showSnack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showLeaveDialog(
    BuildContext ctx,
    List<LeaveBalanceItem> items, {
    required String dateUpto,
    required String employeeName,
  }) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Current Leave Balance',
            style: TextStyle(
                color: AppColors.textColor,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (employeeName.isNotEmpty)
              Text(employeeName,
                  style: const TextStyle(color: AppColors.textColor, fontSize: 18)),
            if (dateUpto.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Up To $dateUpto',
                  style: const TextStyle(color: Color(0xFF666666), fontSize: 16)),
            ],
            const Divider(height: 20),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Expanded(
                      child: Text(item.leaveTypeName ?? '',
                          style: const TextStyle(color: AppColors.textColor, fontSize: 16)),
                    ),
                    const Text(' : ',
                        style: TextStyle(
                            color: AppColors.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(item.balanceHrs ?? '',
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
                  ]),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK',
                style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
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
