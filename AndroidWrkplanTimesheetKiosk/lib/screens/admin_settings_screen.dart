import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSettingCard(
            title: 'Kiosk Unit Settings',
            subtitle: 'Configure kiosk parameters',
            icon: Icons.settings,
            onTap: () {
              Navigator.of(context).pushNamed('/kiosk-settings');
            },
          ),
          _buildSettingCard(
            title: 'Employee Settings',
            subtitle: 'Manage employees',
            icon: Icons.people,
            onTap: () {
              Navigator.of(context).pushNamed('/employee-settings');
            },
          ),
          _buildSettingCard(
            title: 'Employee Image Settings',
            subtitle: 'Upload/manage employee images',
            icon: Icons.image,
            onTap: () {
              Navigator.of(context).pushNamed('/employee-image-settings');
            },
          ),
          _buildSettingCard(
            title: 'Attendance Reports',
            subtitle: 'View attendance data',
            icon: Icons.assessment,
            onTap: () {
              Navigator.of(context).pushNamed('/attendance-reports');
            },
          ),
          _buildSettingCard(
            title: 'System Configuration',
            subtitle: 'API and sync settings',
            icon: Icons.build,
            onTap: () {
              Navigator.of(context).pushNamed('/system-config');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
