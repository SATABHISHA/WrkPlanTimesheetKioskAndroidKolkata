import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../constants/app_colors.dart';

/// Mirrors PunchOutBreakActivity from satabhisha.
///
/// Shows the punch/break status message then automatically redirects to the
/// login screen after 4 seconds.
class PunchStatusScreen extends StatefulWidget {
  const PunchStatusScreen({super.key});

  @override
  State<PunchStatusScreen> createState() => _PunchStatusScreenState();
}

class _PunchStatusScreenState extends State<PunchStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Mirror: Handler.postDelayed(4000) → go back to HomeLoginActivity
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      auth.endSession();
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth       = context.watch<AuthProvider>();
    final isBreak    = auth.punchOutBreak == 'break';
    final statusText = auth.checkedInOut.isNotEmpty
        ? auth.checkedInOut
        : (isBreak ? 'You are on Break!' : 'Good Bye!');
    final now        = DateTime.now();
    final dateStr    = DateFormat('dd-MMM-yyyy').format(now);
    final timeStr    = DateFormat('hh:mm a').format(now);

    final statusColor = isBreak ? AppColors.breakColor : AppColors.punchOut;
    final statusIcon  = isBreak ? Icons.free_breakfast : Icons.waving_hand;

    return Scaffold(
      backgroundColor: AppColors.vkBackground,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 80, color: statusColor),
                const SizedBox(height: 24),
                Text(statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: statusColor)),
                const SizedBox(height: 16),
                Text(auth.user?.empName ?? '',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(dateStr,
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
                Text(timeStr,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                const Text('Returning to login…',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
