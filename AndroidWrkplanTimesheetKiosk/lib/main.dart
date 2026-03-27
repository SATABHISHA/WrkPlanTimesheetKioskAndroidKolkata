import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/shared_preference_helper.dart';
import 'constants/app_constants.dart';
import 'constants/app_theme.dart';
import 'services/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/recognition_option_screen.dart';
import 'screens/task_selection_screen.dart';
import 'screens/punch_status_screen.dart';
import 'screens/attendance_log_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/employee_image_settings_screen.dart';
import 'screens/kiosk_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceHelper.init();
  await AppConstants.loadBaseUrl(); // restore saved server URL
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // Kiosk always starts at the user login screen
        initialRoute: '/login',
        routes: {
          '/login':                    (_) => const LoginScreen(),
          '/recognition-option':        (_) => const RecognitionOptionScreen(),
          '/task-selection':            (_) => const TaskSelectionScreen(),
          '/punch-status':              (_) => const PunchStatusScreen(),
          '/attendance-log':            (_) => const AttendanceLogScreen(),
          '/admin-login':               (_) => const AdminLoginScreen(),
          '/admin-home':                (_) => const AdminHomeScreen(),
          '/employee-image-settings':   (_) => const EmployeeImageSettingsScreen(),
          '/kiosk-settings':            (_) => const KioskSettingsScreen(),
        },
      ),
    );
  }
}

