import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../constants/app_colors.dart';

/// Mirrors AdminHomeActivity from satabhisha – dark navy bg, "Dashboard" title,
/// two cards (Kiosk Unit Settings, Employee Image Settings).
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Dashboard',
            style: TextStyle(color: AppColors.textColor, fontSize: 22)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primary),
            onPressed: () {
              auth.endSession();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _dashCard(
              title: 'Kiosk Unit Settings',
              onTap: () => Navigator.of(context).pushNamed('/kiosk-settings'),
            ),
            const SizedBox(height: 16),
            _dashCard(
              title: 'Employee Image Settings',
              onTap: () =>
                  Navigator.of(context).pushNamed('/employee-image-settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashCard({required String title, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textColor,
          side: const BorderSide(color: AppColors.cardStroke, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
