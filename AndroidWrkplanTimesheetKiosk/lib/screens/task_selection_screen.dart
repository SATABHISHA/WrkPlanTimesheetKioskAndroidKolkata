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
        // Mirror native: show dialog then navigate back
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/recognition-option');
        }
      } else {
        _showSnack(json['message']?.toString() ?? 'Save failed');
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      _showSnack('Could not connect to server');
    }
  }

  void _cancel() {
    Navigator.of(context).pushReplacementNamed('/recognition-option');
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
    final today    = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    final totalHrs = _round(_totalHours(), 2);

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        title: const Text('Select Task',
            style: TextStyle(color: Colors.white, fontSize: 22)),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : Column(
              children: [
                // Header bar
                Container(
                  color: AppColors.cardBg,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.user?.empName ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(today,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Hrs',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(totalHrs.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ],
                    ),
                  ]),
                ),

                // Task list
                Expanded(
                  child: _tasks.isEmpty
                      ? const Center(
                          child: Text('No tasks found',
                              style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (_, i) {
                            final t = _tasks[i];
                            final selected = i == _selectedTaskIdx;
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.cardBg
                                    : AppColors.cardStroke,
                                borderRadius: BorderRadius.circular(8),
                                border: selected
                                    ? Border.all(
                                        color: AppColors.teal, width: 1.5)
                                    : null,
                              ),
                              child: ListTile(
                                onTap: () => _onTaskSelected(i),
                                leading: Radio<int>(
                                  value: i,
                                  groupValue: _selectedTaskIdx,
                                  onChanged: (v) => _onTaskSelected(v!),
                                  activeColor: AppColors.teal,
                                  fillColor: WidgetStateProperty.all(
                                      selected
                                          ? AppColors.teal
                                          : Colors.white54),
                                ),
                                title: Text(t.task ?? '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (t.contract != null &&
                                        t.contract!.isNotEmpty)
                                      Text('Contract: ${t.contract}',
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12)),
                                    if (t.laborCategory != null &&
                                        t.laborCategory!.isNotEmpty)
                                      Text('Category: ${t.laborCategory}',
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12)),
                                  ],
                                ),
                                trailing: Text('${t.hour ?? 0} hrs',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.teal)),
                              ),
                            );
                          },
                        ),
                ),

                // Cancel + Done buttons (native: ll_button at bottom)
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _cancel,
                          child: Container(
                            height: 50,
                            margin: const EdgeInsets.only(right: 1),
                            decoration: BoxDecoration(
                              color: AppColors.dialogOk,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _done,
                          child: Container(
                            height: 50,
                            margin: const EdgeInsets.only(left: 1),
                            decoration: BoxDecoration(
                              color: AppColors.dialogNo,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text('Done',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ),
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
