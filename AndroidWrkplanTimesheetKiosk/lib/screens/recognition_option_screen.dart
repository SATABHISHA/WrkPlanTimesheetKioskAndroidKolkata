import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: const BoxDecoration(
                color: AppColors.dialogHeader,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Text('Current Leave Balance',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600)),
            ),
            // Body
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.dialogBody,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (employeeName.isNotEmpty)
                    Text(employeeName,
                        style: const TextStyle(
                            color: AppColors.dialogText, fontSize: 20)),
                  if (dateUpto.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(dateUpto,
                        style: const TextStyle(
                            color: AppColors.dialogText, fontSize: 18)),
                  ],
                  const Divider(color: Color(0xFF738BB0), height: 20),
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 190,
                              child: Text(item.leaveTypeName ?? '',
                                  style: const TextStyle(
                                      color: AppColors.dialogText,
                                      fontSize: 18)),
                            ),
                            const Text(' : ',
                                style: TextStyle(
                                    color: AppColors.dialogText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(item.balanceHrs ?? '',
                                style: const TextStyle(
                                    color: AppColors.dialogText,
                                    fontSize: 18)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            // OK button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.dialogOk,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('OK',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
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
    final now  = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _checkAttendanceStatus,
          ),
        ],
      ),
      body: _loadingAction
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top info card (bg #DDE5FF, rounded 15) ───────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightCard,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.lightCard, width: 2),
                    ),
                    child: Column(
                      children: [
                        // ── Teal headline area (#55D5BE, top-rounded) ──────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello\n ${user.empName ?? user.userName ?? ''}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    'Date: ${DateFormat('dd-MMM-yyyy').format(now)}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    'Time: ${DateFormat('HH:mm a').format(now)}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // ── Info fields (emp id, supervisors) ──────────────
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              _infoRow('Employee ID', user.employeeCode ?? ''),
                              _infoRow('Supervisor 1', user.supervisor1 ?? ''),
                              _infoRow('Supervisor 2', user.supervisor2 ?? ''),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Punch IN ─────────────────────────────────────────────
                  if (_nextAction == 'IN' || _nextAction.isEmpty)
                    _actionBtn(
                      topText: 'Punch', bottomText: 'IN',
                      color: AppColors.cardBg,
                      height: 80,
                      onTap: _onPunchIn,
                    ),

                  // ── Break + Punch OUT side by side ───────────────────────
                  if (_nextAction == 'OUT') ...[
                    Row(
                      children: [
                        Expanded(
                          child: _actionBtn(
                            topText: 'Take a', bottomText: 'BREAK',
                            color: AppColors.breakColor,
                            height: 80,
                            onTap: _onBreak,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionBtn(
                            topText: 'Punch', bottomText: 'OUT',
                            color: AppColors.punchOut,
                            height: 80,
                            onTap: _onPunchOut,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),

                  // ── View / Select Task ───────────────────────────────────
                  if (_nextAction == 'OUT') ...[
                    _actionBtn(
                      bottomText: 'View / Select / Switch Task',
                      color: AppColors.cardBg,
                      height: 74,
                      onTap: () =>
                          Navigator.of(context).pushNamed('/task-selection'),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ── View Leave Balance ───────────────────────────────────
                  _actionBtn(
                    bottomText: 'View Leave Balance',
                    color: AppColors.cardBg,
                    height: 74,
                    onTap: _showLeaveBalance,
                  ),
                  const SizedBox(height: 10),

                  // ── View Attendance ──────────────────────────────────────
                  _actionBtn(
                    bottomText: 'View Attendance',
                    color: AppColors.cardBg,
                    height: 74,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/attendance-log'),
                  ),
                  const SizedBox(height: 10),

                  // ── Logout ──────────────────────────────────────────────
                  _actionBtn(
                    bottomText: 'Logout',
                    color: AppColors.cardBg,
                    height: 74,
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          const Text(' : ', style: TextStyle(color: Colors.white, fontSize: 14)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    String? topText,
    required String bottomText,
    required Color color,
    double height = 74,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: AppColors.cardStroke, width: 2),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (topText != null)
              Text(topText,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            Text(bottomText,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

