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

    final statusColor = isBreak ? AppColors.breakColor : AppColors.punchOut;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Column(
        children: [
          // Spacer to centre the content
          const Spacer(),

          // Status icon (check or break)
          Icon(
            isBreak ? Icons.free_breakfast : Icons.check_circle_outline,
            size: 100,
            color: statusColor,
          ),
          const SizedBox(height: 20),

          // Status text
          Text(statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: statusColor)),
          const SizedBox(height: 12),

          // Employee name
          Text(auth.user?.empName ?? '',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 8),

          // Date + time
          Text(dateStr,
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
          Text(timeStr,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),

          const Spacer(),

          // Footer: kiosklogo + version + copyright (mirrors native layout)
          SizedBox(
            height: 50,
            child: Image.asset('assets/images/kiosklogo.png',
                fit: BoxFit.contain),
          ),
          const SizedBox(height: 6),
          const Text('Version 1.0',
              style: TextStyle(color: Colors.white54, fontSize: 11)),
          const Text('\u00a9 Jeebr Technologies Pvt. Ltd.',
              style: TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
