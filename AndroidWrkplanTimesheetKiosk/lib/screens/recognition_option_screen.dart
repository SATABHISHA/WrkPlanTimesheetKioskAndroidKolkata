import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../models/task_model.dart';
import '../utils/shared_preference_helper.dart';
import '../constants/app_colors.dart';

/// Mirrors RecognitionOptionActivity from satabhisha.
///
/// This is the main kiosk hub shown after login.  It loads the attendance
/// next-action (IN / OUT) and shows the appropriate punch controls.
class RecognitionOptionScreen extends StatefulWidget {
  const RecognitionOptionScreen({super.key});

  @override
  State<RecognitionOptionScreen> createState() => _RecognitionOptionScreenState();
}

class _RecognitionOptionScreenState extends State<RecognitionOptionScreen> {
  final _api   = ApiService();
  final _prefs = SharedPreferenceHelper();

  String  _nextAction   = ''; // 'IN' or 'OUT'
  bool    _loadingAction = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAttendanceStatus());
  }

  // ─── Load next attendance action ─────────────────────────────────────────

  Future<void> _checkAttendanceStatus() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loadingAction = true);
    try {
      final json = await _api.getAttendanceNextAction(
        corpId: auth.user!.corpID!,
        userId: auth.user!.personId!,
      );
      setState(() {
        _nextAction   = json['next_action']?.toString().toUpperCase() ?? 'IN';
        _loadingAction = false;
      });
    } catch (_) {
      setState(() => _loadingAction = false);
    }
  }

  // ─── Location validation (mirrors location-based punch from satabhisha) ──

  Future<bool> _validateLocation() async {
    final officeLat    = _prefs.getOfficeLat();
    final officeLon    = _prefs.getOfficeLon();
    final punchRadius  = _prefs.getPunchRadius();

    // If no office coordinates configured, skip location check
    if (officeLat == 0.0 && officeLon == 0.0) return true;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      _showSnack('Location permission required for punch');
      return false;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      _showDialog('Location Required',
          'Please enable GPS and try again.');
      return false;
    }

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final distance = Geolocator.distanceBetween(
        pos.latitude, pos.longitude, officeLat, officeLon);

    if (distance > punchRadius) {
      _showSnack(
          'You are ${distance.toStringAsFixed(0)} m away. Must be within ${punchRadius.toStringAsFixed(0)} m.');
      return false;
    }
    return true;
  }

  // ─── Punch actions ────────────────────────────────────────────────────────

  void _onPunchIn() async {
    if (!await _validateLocation()) return;
    _saveInOut('IN', 'PUNCHED_IN');
  }

  void _onBreak() async {
    if (!await _validateLocation()) return;
    _saveInOut('OUT', 'BREAK_STARTS');
  }

  void _onPunchOut() async {
    // Show confirmation dialog like Android break_punchout()
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Punch Out'),
        content: const Text('Are you sure you want to punch out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Punch Out')),
        ],
      ),
    );
    if (confirm != true) return;
    if (!await _validateLocation()) return;
    _saveInOut('OUT', 'PUNCH_OUT');
  }

  Future<void> _saveInOut(String inOut, String inOutText) async {
    final auth = context.read<AuthProvider>();
    _showLoading('Saving…');
    try {
      final json = await _api.saveAttendance(
        corpId:    auth.user!.corpID!,
        userId:    auth.user!.personId!,
        inOut:     inOut,
        inOutText: inOutText,
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      final attendanceId = json['attendance_id']?.toString() ?? '';
      final responseObj  = json['response'] as Map<String, dynamic>? ?? {};
      final status       = responseObj['status']?.toString() ?? '';

      if (status == 'true') {
        auth.attendanceId     = attendanceId;
        auth.isInOutButtonHit = (inOut == 'IN');

        if (inOut == 'IN') {
          // Mirror: go to AttendanceRecordActivity
          Navigator.of(context).pushNamed('/task-selection');
        } else {
          if (inOutText == 'BREAK_STARTS') {
            auth.punchOutBreak = 'break';
            auth.checkedInOut  = 'You are on Break!';
            await _taskHourUpdate(auth);
          } else {
            auth.punchOutBreak = 'out';
            auth.checkedInOut  = 'Good Bye!';
            await _taskHourSubmit(auth);
          }
          Navigator.of(context).pushReplacementNamed('/punch-status');
        }
      } else {
        _showSnack('Failed: ${responseObj['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showSnack('Could not connect to server');
    }
  }

  Future<void> _taskHourUpdate(AuthProvider auth) async {
    try {
      await _api.taskHourUpdate(
          corpId: auth.user!.corpID!, userId: auth.user!.personId!);
    } catch (_) {}
  }

  Future<void> _taskHourSubmit(AuthProvider auth) async {
    try {
      await _api.taskHourSubmit(
          corpId: auth.user!.corpID!, userId: auth.user!.personId!);
    } catch (_) {}
  }

  // ─── Leave Balance dialog (mirrors RecognitionOptionActivity.loadLeaveBalanceData) ─

  void _showLeaveBalance() async {
    final auth = context.read<AuthProvider>();
    _showLoading('Loading…');
    try {
      final json = await _api.getLeaveBalance(
        corpId: auth.user!.corpID!,
        employeeId: auth.user!.personId!,
      );
      if (!mounted) return;
      Navigator.of(context).pop();

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
          _showSnack('No leave balance data found');
          return;
        }

        _showLeaveDialog(
          items,
          dateUpto: json['LeaveDateUpto']?.toString() ?? '',
          employeeName: auth.user?.empName ?? auth.user?.userName ?? '',
        );
      } else {
        _showSnack(json['message']?.toString() ?? 'No data');
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      _showSnack('Could not connect to server');
    }
  }

  void _showLeaveDialog(
    List<LeaveBalanceItem> items, {
    required String dateUpto,
    required String employeeName,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave Balance'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (employeeName.isNotEmpty)
                Text(employeeName,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              if (dateUpto.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(dateUpto, style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    title: Text(items[i].leaveTypeName ?? ''),
                    trailing: Text(
                      items[i].balanceHrs ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _showLoading(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Text(msg),
        ]),
      ),
    );
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _showDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;

    return Scaffold(
      backgroundColor: AppColors.vkBackground,
      appBar: AppBar(
        title: const Text('Kiosk'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _checkAttendanceStatus,
          ),
        ],
      ),
      body: _loadingAction
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Employee name greeting
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello,',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14)),
                          Text(user.empName ?? user.userName ?? '',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                          if (user.companyName != null)
                            Text(user.companyName!,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Punch IN (visible when next_action = 'IN') ─────────
                  if (_nextAction == 'IN' || _nextAction.isEmpty)
                    _ActionCard(
                      label: 'Punch IN',
                      icon: Icons.login,
                      color: AppColors.punchIn,
                      onTap: _onPunchIn,
                    ),

                  // ─── Break + Punch OUT (visible when next_action = 'OUT') ─
                  if (_nextAction == 'OUT') ...[
                    _ActionCard(
                      label: 'Break',
                      icon: Icons.free_breakfast,
                      color: AppColors.breakColor,
                      onTap: _onBreak,
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      label: 'Punch OUT',
                      icon: Icons.logout,
                      color: AppColors.punchOut,
                      onTap: _onPunchOut,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ─── Select / View Task ──────────────────────────────────
                  if (_nextAction == 'OUT')
                    _ActionCard(
                      label: 'Select / View Task',
                      icon: Icons.task_alt,
                      color: AppColors.primary,
                      onTap: () => Navigator.of(context).pushNamed('/task-selection'),
                    ),

                  const SizedBox(height: 12),

                  // ─── Leave Balance ───────────────────────────────────────
                  _ActionCard(
                    label: 'Leave Balance',
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.primaryVariant,
                    onTap: _showLeaveBalance,
                  ),
                  const SizedBox(height: 12),

                  // ─── View Attendance ─────────────────────────────────────
                  _ActionCard(
                    label: 'View Attendance',
                    icon: Icons.history,
                    color: AppColors.secondary,
                    onTap: () {
                      Navigator.of(context).pushNamed('/attendance-log');
                    },
                  ),
                  const SizedBox(height: 24),

                  // End session (returns to login)
                  TextButton.icon(
                    onPressed: () {
                      auth.endSession();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('End Session'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String   label;
  final IconData icon;
  final Color    color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Text(label,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: color)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ]),
        ),
      ),
    );
  }
}
