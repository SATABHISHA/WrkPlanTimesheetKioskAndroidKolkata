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
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text('Dashboard',
            style: TextStyle(color: Colors.white, fontSize: 22)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.dashCardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dashCardStroke, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
