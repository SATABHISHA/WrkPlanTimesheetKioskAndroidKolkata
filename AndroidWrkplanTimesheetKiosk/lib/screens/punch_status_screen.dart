import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../constants/app_colors.dart';

/// Mirrors PunchOutBreakActivity from satabhisha – dark navy background,
/// centred status message, kiosklogo footer with version/copyright.
class PunchStatusScreen extends StatefulWidget {
  const PunchStatusScreen({super.key});

  @override
  State<PunchStatusScreen> createState() => _PunchStatusScreenState();
}

class _PunchStatusScreenState extends State<PunchStatusScreen> {
  @override
  void initState() {
    super.initState();
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

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(auth.user?.empName ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(width: 10),
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Centered status area (gravity="center") ──────────────────
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status icon (60dp)
                  Icon(
                    isBreak ? Icons.free_breakfast : Icons.check_circle_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 25),

                  // Status text (32sp, white, centerHorizontal)
                  Text(statusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 15),

                  // Date (17sp, white, centerHorizontal)
                  Text(dateStr,
                      style: const TextStyle(
                          fontSize: 17, color: Colors.white)),
                  const SizedBox(height: 5),

                  // Time (17sp, white, centerHorizontal)
                  Text(timeStr,
                      style: const TextStyle(
                          fontSize: 17, color: Colors.white)),
                ],
              ),
            ),
          ),

          // ── Footer (180dp, alignParentBottom) ────────────────────────
          SizedBox(
            height: 180,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Image.asset('assets/images/kiosklogo.png',
                      fit: BoxFit.contain),
                ),
                const SizedBox(height: 20),
                const Text('Version 1.0',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 5),
                const Text('\u00a9 WrkPlan Technologies Pvt. Ltd.',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
