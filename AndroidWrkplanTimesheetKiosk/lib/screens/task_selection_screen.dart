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

  // Mirrors static variables in TaskSelectionActivity
  int    _contractID  = 0;
  int    _taskId      = 0;
  int    _laborCatId  = 0;
  int    _costTypeId  = 0;
  int    _acSuffix    = 0;

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
          _contractID  = list[i].contractID  ?? 0;
          _taskId      = list[i].taskID      ?? 0;
          _laborCatId  = list[i].laborCategoryID ?? 0;
          _costTypeId  = list[i].costTypeID  ?? 0;
          _acSuffix    = list[i].acSuffix    ?? 0;
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
    final t = _tasks[idx];
    setState(() {
      _selectedTaskIdx = idx;
      _contractID = t.contractID  ?? 0;
      _taskId     = t.taskID      ?? 0;
      _laborCatId = t.laborCategoryID ?? 0;
      _costTypeId = t.costTypeID  ?? 0;
      _acSuffix   = t.acSuffix   ?? 0;
    });
  }

  void _done() async {
    final auth = context.read<AuthProvider>();
    _showLoading('Saving…');
    try {
      Map<String, dynamic> json;
      if (!auth.isInOutButtonHit) {
        // Mirror: saveInOut("TC","TASK_CHANGED")
        json = await _api.saveAttendance(
          corpId:    auth.user!.corpID!,
          userId:    auth.user!.personId!,
          inOut:     'TC',
          inOutText: 'TASK_CHANGED',
        );
      } else {
        json = await _api.taskHourSave(
          corpId:               auth.user!.corpID!,
          userId:               auth.user!.personId!,
          employeeAssignmentId: auth.employeeAssignmentID ?? '',
          kioskAttendanceId:    auth.attendanceId ?? '',
          contractId:           _contractID,
          taskId:               _taskId,
          laborCatId:           _laborCatId,
          costTypeId:           _costTypeId,
          suffixCode:           _acSuffix,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      final status = json['status']?.toString() ?? '';
      if (status == 'true') {
        Navigator.of(context).pushReplacementNamed('/recognition-option');
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
      appBar: AppBar(
        title: const Text('Select Task'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _cancel,
            child: const Text('CANCEL',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header card
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                      ? const Center(child: Text('No tasks found'))
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (_, i) {
                            final t        = _tasks[i];
                            final selected = i == _selectedTaskIdx;
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              color: selected
                                  ? AppColors.primary.withAlpha(20)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: selected
                                    ? const BorderSide(
                                        color: AppColors.primary, width: 1.5)
                                    : BorderSide.none,
                              ),
                              child: ListTile(
                                onTap: () => _onTaskSelected(i),
                                leading: Radio<int>(
                                  value: i,
                                  groupValue: _selectedTaskIdx,
                                  onChanged: (v) => _onTaskSelected(v!),
                                  activeColor: AppColors.primary,
                                ),
                                title: Text(t.task ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (t.contract != null && t.contract!.isNotEmpty)
                                      Text('Contract: ${t.contract}',
                                          style: const TextStyle(fontSize: 12)),
                                    if (t.laborCategory != null &&
                                        t.laborCategory!.isNotEmpty)
                                      Text('Category: ${t.laborCategory}',
                                          style: const TextStyle(fontSize: 12)),
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

                // Done button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _done,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppColors.punchIn),
                    child: const Text('DONE',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }
}
