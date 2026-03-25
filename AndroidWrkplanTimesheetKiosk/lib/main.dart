import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/shared_preference_helper.dart';
import 'services/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recognition_screen.dart';
import 'screens/attendance_log_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'screens/kiosk_settings_screen.dart';
import 'screens/employee_settings_screen.dart';
import 'screens/employee_image_settings_screen.dart';
import 'screens/attendance_reports_screen.dart';
import 'screens/system_config_screen.dart';
import 'constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  await SharedPreferenceHelper.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
      ],
      child: MaterialApp(
        title: 'WrkPlan Timesheet Kiosk',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/admin-login': (context) => const AdminLoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/recognition': (context) => const RecognitionScreen(),
          '/attendance-log': (context) => const AttendanceLogScreen(),
          '/admin-settings': (context) => const AdminSettingsScreen(),
          '/admin-home': (context) => const AdminSettingsScreen(),
          '/kiosk-settings': (context) => const KioskSettingsScreen(),
          '/employee-settings': (context) => const EmployeeSettingsScreen(),
          '/employee-image-settings': (context) =>
              const EmployeeImageSettingsScreen(),
          '/attendance-reports': (context) => const AttendanceReportsScreen(),
          '/system-config': (context) => const SystemConfigScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
