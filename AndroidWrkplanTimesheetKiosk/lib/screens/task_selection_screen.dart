import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../models/task_model.dart';
import '../constants/app_colors.dart';

/// Mirrors TaskSelectionActivity from satabhisha.
///
/// Shows the employee's daily task list with editable hours.
/// Done → TaskHourSave; Cancel → back to RecognitionOptionScreen.
class TaskSelectionScreen extends StatefulWidget {
  const TaskSelectionScreen({super.key});

  @override
  State<TaskSelectionScreen> createState() => _TaskSelectionScreenState();
}

class _TaskSelectionScreenState extends State<TaskSelectionScreen> {
  final _api = ApiService();

  List<TaskModel>  _tasks      = [];
  bool             _loading    = true;
  int              _selectedTaskIdx = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      final json = await _api.getTaskList(
        corpId: auth.user!.corpID!,
        userId: auth.user!.personId!,
      );

      final raw = json['EmployeeTimeSheetDetails'];
      final list = (raw is List ? raw : (raw != null ? [raw] : []))
          .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      // Mirror: select default task (DefaultTaskYn == 1)
      int defaultIdx = -1;
      for (int i = 0; i < list.length; i++) {
        if (list[i].defaultTaskYn == 1) {
          defaultIdx = i;
        }
      }

      setState(() {
        _tasks           = list;
        _selectedTaskIdx = defaultIdx;
        _loading         = false;
      });
    } catch (_) {
      setState(() => _loading = false);
      _showSnack('Could not connect to server');
    }
  }

  double _totalHours() =>
      _tasks.fold(0.0, (sum, t) => sum + t.parsedHour);

  // Rounds to 2 decimal places (mirrors TaskSelectionAdapter.round)
  static double _round(double value, int places) {
    final mod = 10.0 * places;
    return ((value * mod).round().toDouble() / mod);
  }

  void _onTaskSelected(int idx) {
    setState(() {
      _selectedTaskIdx = idx;
    });
  }

  void _done() async {
    final auth = context.read<AuthProvider>();
    _showLoading('Saving…');
    try {
      if (!auth.isInOutButtonHit) {
        // Mirror native: saveInOut("TC","TASK_CHANGED") first
        final saveJson = await _api.saveAttendance(
          corpId:    auth.user!.corpID!,
          userId:    auth.user!.personId!,
          inOut:     'TC',
          inOutText: 'TASK_CHANGED',
        );

        // Extract attendance_id from saveAttendance response
        final aid = saveJson['attendance_id']?.toString() ?? '0';
        auth.attendanceId = aid;

        // Check nested response.status
        final resp = saveJson['response'];
        final status = (resp is Map ? resp['status']?.toString() : saveJson['status']?.toString()) ?? '';
        if (status.toLowerCase() != 'true') {
          if (mounted) Navigator.of(context).pop();
          _showSnack(resp is Map ? resp['message']?.toString() ?? 'Internal error' : 'Internal error');
          return;
        }
      }

      // Mirror native: save() → TaskHourSave with minimal params only
      final json = await _api.taskHourSaveOnCancel(
        corpId:               auth.user!.corpID!,
        userId:               auth.user!.personId!,
        employeeAssignmentId: auth.employeeAssignmentID ?? '0',
        kioskAttendanceId:    auth.attendanceId ?? '0',
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      final status = json['status']?.toString().toLowerCase() ?? '';
      if (status == 'true') {
        // Show animated success then go back
        if (mounted) {
          await _showSuccessOverlay('Task Saved Successfully!');
          if (mounted) {
            Navigator.of(context).pop(); // return to punch status screen
          }
        }
      } else {
        _showSnack(json['message']?.toString() ?? 'Save failed');
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      _showSnack('Could not connect to server');
    }
  }

  Future<void> _showSuccessOverlay(String message) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.elasticOut);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (_, value, __) => Transform.scale(
                      scale: value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Auto-dismiss after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // dismiss the success dialog
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

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

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final today    = DateFormat('MM/dd/yy').format(DateTime.now());
    final totalHrs = _round(_totalHours(), 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Select Task',
            style: TextStyle(color: AppColors.textColor, fontSize: 22)),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Header bar
                Container(
                  color: Colors.grey.shade50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.user?.empName ?? '',
                              style: const TextStyle(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(today,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total Hrs',
                            style:
                                TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        Text(totalHrs.toString(),
                            style: const TextStyle(
                                color: AppColors.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ],
                    ),
                  ]),
                ),

                // Task list
                Expanded(
                  child: _tasks.isEmpty
                      ? Center(
                          child: Text('No tasks found',
                              style: TextStyle(color: Colors.grey.shade500)))
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (_, i) {
                            final t = _tasks[i];
                            final selected = i == _selectedTaskIdx;
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.cardStroke,
                                    width: selected ? 2 : 1),
                              ),
                              child: ListTile(
                                onTap: () => _onTaskSelected(i),
                                leading: Radio<int>(
                                  value: i,
                                  groupValue: _selectedTaskIdx,
                                  onChanged: (v) => _onTaskSelected(v!),
                                  activeColor: AppColors.primary,
                                  fillColor: WidgetStateProperty.all(
                                      selected
                                          ? AppColors.primary
                                          : Colors.grey),
                                ),
                                title: Text(t.task ?? '',
                                    style: const TextStyle(
                                        color: AppColors.textColor,
                                        fontWeight: FontWeight.w600)),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (t.contract != null &&
                                        t.contract!.isNotEmpty)
                                      Text('Contract: ${t.contract}',
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12)),
                                    if (t.laborCategory != null &&
                                        t.laborCategory!.isNotEmpty)
                                      Text('Category: ${t.laborCategory}',
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12)),
                                  ],
                                ),
                                trailing: Text('${t.hour ?? 0} hrs',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary)),
                              ),
                            );
                          },
                        ),
                ),

                // Cancel + Done buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textColor,
                            side: const BorderSide(color: AppColors.cardStroke),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _done,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Done',
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
