import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../models/task_model.dart';
import '../utils/shared_preference_helper.dart';
import '../utils/punch_validator.dart';
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
    if (!await PunchValidator.validate(context)) return;
    _saveInOut('IN', 'PUNCHED_IN');
  }

  void _onBreak() async {
    if (!await PunchValidator.validate(context)) return;
    _saveInOut('OUT', 'BREAK_STARTS');
  }

  void _onPunchOut() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Punch Out?',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textColor, fontSize: 22, fontWeight: FontWeight.w600)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'punchout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.punchOut,
              side: const BorderSide(color: AppColors.punchOut),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Punch Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'break'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Break', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (result == null) return;
    if (!await PunchValidator.validate(context)) return;
    if (result == 'punchout') {
      _saveInOut('OUT', 'PUNCHED_OUT');
    } else {
      _saveInOut('OUT', 'BREAK_STARTS');
    }
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
          auth.punchOutBreak = '';
          auth.checkedInOut  = 'You Are In';
          Navigator.of(context).pushReplacementNamed('/punch-status');
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
          // employeeName: auth.user?.empName ?? auth.user?.userName ?? '',
          employeeName: 'Emma Beck',
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
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Current Leave Balance',
            style: TextStyle(
                color: AppColors.textColor,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (employeeName.isNotEmpty)
              Text(employeeName,
                  style: const TextStyle(
                      color: AppColors.textColor, fontSize: 18)),
            if (dateUpto.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Up To $dateUpto',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 16)),
            ],
            const Divider(height: 20),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item.leaveTypeName ?? '',
                            style: const TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16)),
                      ),
                      const Text(' : ',
                          style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text(item.balanceHrs ?? '',
                          style: const TextStyle(
                              color: AppColors.textColor,
                              fontSize: 16)),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('OK',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
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
    if (auth.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    final user = auth.user!;
    final now  = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'WRKPLAN',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _checkAttendanceStatus,
          ),
        ],
      ),
      body: _loadingAction
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ──────────────────────────────────────────
                  const Text('Hello',
                      style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w500)),
                  Text(
                    // user.empName ?? user.userName ?? '',
                    'Emma Beck',
                    style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${DateFormat('MM/dd/yy').format(now)}  Time: ${DateFormat('hh:mm a').format(now)}',
                    style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 28),

                  // ── Employee info card (Punch IN view only) ──────────
                  if (_nextAction == 'IN' || _nextAction.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.fieldBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoCardRow(Icons.badge_outlined, 'Employee ID', user.employeeCode ?? ''),
                          const SizedBox(height: 10),
                          _infoCardRow(Icons.person_outline, 'Supervisor 1', user.supervisor1 ?? ''),
                          const SizedBox(height: 10),
                          _infoCardRow(Icons.person_outline, 'Supervisor 2', user.supervisor2 ?? ''),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Punch IN ─────────────────────────────────────────
                  if (_nextAction == 'IN' || _nextAction.isEmpty)
                    _actionBtn(
                      label: 'Punch IN',
                      filled: true,
                      onTap: _onPunchIn,
                    ),

                  // ── Break + Punch OUT ─────────────────────────────────
                  if (_nextAction == 'OUT') ..._outButtons(),

                  const SizedBox(height: 12),

                  // ── View / Select Task ───────────────────────────────
                  if (_nextAction == 'OUT') ...[
                    _actionBtn(
                      label: 'View / Select / Switch Task',
                      onTap: () =>
                          Navigator.of(context).pushNamed('/task-selection'),
                    ),
                    const SizedBox(height: 12),
                  ],

                  _actionBtn(
                    label: 'View Leave Balance',
                    onTap: _showLeaveBalance,
                  ),
                  const SizedBox(height: 12),

                  _actionBtn(
                    label: 'View Attendance',
                    onTap: () =>
                        Navigator.of(context).pushNamed('/attendance-log'),
                  ),
                  const SizedBox(height: 12),

                  _actionBtn(
                    label: 'Logout',
                    onTap: () {
                      auth.endSession();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _outButtons() {
    return [
      _actionBtn(
        label: 'Take a BREAK',
        filled: true,
        color: const Color(0xFFFFC107),
        onTap: _onBreak,
      ),
      const SizedBox(height: 12),
      _actionBtn(
        label: 'Punch OUT',
        filled: true,
        color: AppColors.punchOut,
        onTap: _onPunchOut,
      ),
    ];
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          ),
          const Text(': ', style: TextStyle(color: AppColors.textColor, fontSize: 14)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: AppColors.textColor, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _infoCardRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    bool filled = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    final btnColor = color ?? AppColors.primary;
    final fgColor = (btnColor == const Color(0xFFFFC107))
        ? AppColors.textColor
        : AppColors.white;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: fgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textColor,
                side: const BorderSide(color: AppColors.secondary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500)),
            ),
    );
  }
}

