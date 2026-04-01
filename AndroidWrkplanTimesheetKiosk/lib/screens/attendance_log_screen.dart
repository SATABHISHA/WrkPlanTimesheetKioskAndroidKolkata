import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_provider.dart';
import '../constants/app_colors.dart';

/// Attendance log screen – redesigned per PDF page 7 with card-style tables.
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

  static const _green = AppColors.secondary; // #81B1AE

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
    final auth    = context.watch<AuthProvider>();
    // final empName = auth.user?.empName ?? '';
    final empName = 'Emma Beck';
    final dateLabel = _selectedDate != null
        ? DateFormat('MM/dd/yy').format(_selectedDate!)
        : 'Select Date';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Attendance Log',
            style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Employee + Date picker card ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _green.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(empName,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor)),
                  ),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _green),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(dateLabel,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_shown) ...[
              // ── IN / OUT Section ──────────────────────────────────────
              _sectionHeader(Icons.login, 'IN / OUT'),
              const SizedBox(height: 10),
              _styledTable(
                headers: ['IN', 'OUT'],
                rows: _logEntries
                    .map((e) => [e['time_in']!, e['time_out']!])
                    .toList(),
              ),
              const SizedBox(height: 24),

              // ── BREAK TAKEN Section ───────────────────────────────────
              _sectionHeader(Icons.coffee_outlined, 'BREAK TAKEN'),
              const SizedBox(height: 10),
              _styledTable(
                headers: ['START', 'END', 'DURATION'],
                rows: _breakEntries
                    .map((e) => [e['start']!, e['end']!, e['duration']!])
                    .toList(),
              ),
            ],

            if (!_shown)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 64, color: _green.withOpacity(0.6)),
                    const SizedBox(height: 12),
                    Text('Select a date to view attendance',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Section header with icon ────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
                letterSpacing: 0.5)),
      ],
    );
  }

  // ── Styled card-table ───────────────────────────────────────────────────

  Widget _styledTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _green.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: headers
                  .map((h) => Expanded(
                        child: Text(h,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8)),
                      ))
                  .toList(),
            ),
          ),
          // Data rows
          ...List.generate(rows.length, (i) {
            final isEven = i.isEven;
            return Container(
              color: isEven ? AppColors.background : AppColors.fieldBg,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: rows[i]
                    .map((val) => Expanded(
                          child: Text(val,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}
