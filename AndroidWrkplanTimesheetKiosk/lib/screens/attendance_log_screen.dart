import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../constants/app_colors.dart';

/// Mirrors ActivityAttendanceLog from satabhisha.
class AttendanceLogScreen extends StatefulWidget {
  const AttendanceLogScreen({super.key});

  @override
  State<AttendanceLogScreen> createState() => _AttendanceLogScreenState();
}

class _AttendanceLogScreenState extends State<AttendanceLogScreen> {
  DateTime? _selectedDate;
  final List<Map<String, String>> _logEntries   = [];
  final List<Map<String, String>> _breakEntries = [];
  bool _shown = false;

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _shown = true;
        // mirrors static JSON sample in ActivityAttendanceLog
        _logEntries
          ..clear()
          ..addAll([
            {'time_in': '11:37 AM', 'time_out': '11:45 AM'},
            {'time_in': '11:47 AM', 'time_out': '04:54 PM'},
            {'time_in': '04:56 PM', 'time_out': '04:58 PM'},
          ]);
        _breakEntries
          ..clear()
          ..addAll([
            {'start': '11:45 AM', 'end': '11:47 AM', 'duration': '2 mins'},
            {'start': '04:54 PM', 'end': '04:56 PM', 'duration': '2 mins'},
          ]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final empName   = auth.user?.empName ?? '';
    final dateLabel = _selectedDate != null
        ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
        : 'Select Date';
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Log')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Hello\n$empName',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryVariant),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: AppColors.primaryVariant),
                  const SizedBox(width: 12),
                  Text(dateLabel,
                      style: const TextStyle(fontSize: 16, color: AppColors.primary)),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primaryVariant),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            if (_shown) ...[
              Text('Attendance Log — $dateLabel',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.grey),
                children: [
                  _headerRow(AppColors.primary, ['Time In', 'Time Out']),
                  ..._logEntries.map((e) => _dataRow([e['time_in']!, e['time_out']!])),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Break Log',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                      color: AppColors.breakColor)),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.grey),
                children: [
                  _headerRow(AppColors.breakColor, ['Start', 'End', 'Duration']),
                  ..._breakEntries.map((e) =>
                      _dataRow([e['start']!, e['end']!, e['duration']!])),
                ],
              ),
            ],
          ],
        ),
      ),
    );
    }

    TableRow _headerRow(Color bg, List<String> cols) => TableRow(
      decoration: BoxDecoration(color: bg),
      children: cols
        .map((c) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text(c,
            style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold))))
        .toList(),
      );

    TableRow _dataRow(List<String> cols) => TableRow(
      children: cols
        .map((c) =>
          Padding(padding: const EdgeInsets.all(8), child: Text(c)))
        .toList(),
      );
  }
