import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../constants/app_colors.dart';

/// Attendance log screen – high-contrast tables with IN/OUT and BREAK TAKEN.
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
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            surface: AppColors.background,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _shown = true;
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
        ? DateFormat('MM/dd/yy').format(_selectedDate!)
        : 'Select Date';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Attendance Log',
            style: TextStyle(color: AppColors.textColor, fontSize: 22)),
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Employee name row + date picker
            Row(
              children: [
                Expanded(
                  child: Text('Employee Name: $empName',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor)),
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.cardStroke),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text('Select Date: $dateLabel',
                            style: const TextStyle(
                                fontSize: 15, color: AppColors.textColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_shown) ...[
              // IN / OUT table
              Table(
                border: TableBorder.all(color: AppColors.textColor, width: 0.5),
                children: [
                  _headerRow(['IN', 'OUT']),
                  ..._logEntries.map((e) =>
                      _dataRow([e['time_in']!, e['time_out']!])),
                ],
              ),
              const SizedBox(height: 28),

              // BREAK TAKEN table
              const Text('BREAK TAKEN',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor)),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: AppColors.textColor, width: 0.5),
                children: [
                  _headerRow(['START', 'END', 'DURATION']),
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

  TableRow _headerRow(List<String> cols) => TableRow(
        decoration: BoxDecoration(color: Colors.grey.shade100),
        children: cols
            .map((c) => Padding(
                padding: const EdgeInsets.all(10),
                child: Text(c,
                    style: const TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15))))
            .toList(),
      );

  TableRow _dataRow(List<String> cols) => TableRow(
        children: cols
            .map((c) => Padding(
                padding: const EdgeInsets.all(10),
                child: Text(c,
                    style: const TextStyle(
                        color: AppColors.textColor, fontSize: 15))))
            .toList(),
      );
}
