import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../constants/app_colors.dart';

/// Punch status screen – shows "You Are In", "You are on Break!" or "Good Bye!"
/// with action buttons matching the v2 high-contrast light design.
class PunchStatusScreen extends StatelessWidget {
  const PunchStatusScreen({super.key});

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

                  // Status text
                  Text(statusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(height: 12),

                  // Date
                  Text(dateStr,
                      style: TextStyle(
                          fontSize: 18, color: Colors.grey.shade700)),
                  const SizedBox(height: 4),

                  // Time
                  Text(timeStr,
                      style: TextStyle(
                          fontSize: 18, color: Colors.grey.shade700)),

                  const Spacer(flex: 1),

                  // Action buttons
                  if (!isOut) ...[
                    _outlinedBtn(context, 'View / Select / Switch Task',
                        () => Navigator.of(context).pushNamed('/task-selection')),
                    const SizedBox(height: 12),
                    _outlinedBtn(context, 'View Leave Balance', () {
                      Navigator.of(context).pushReplacementNamed('/recognition-option');
                    }),
                    const SizedBox(height: 12),
                  ],

                  Center(
                    child: TextButton(
                      onPressed: () {
                        auth.endSession();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text('Logout',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlinedBtn(BuildContext context, String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textColor,
          side: const BorderSide(color: AppColors.cardStroke, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
