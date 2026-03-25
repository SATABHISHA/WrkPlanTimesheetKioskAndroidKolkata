import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class EmployeeSettingsScreen extends StatefulWidget {
  const EmployeeSettingsScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeSettingsScreen> createState() =>
      _EmployeeSettingsScreenState();
}

class _EmployeeSettingsScreenState extends State<EmployeeSettingsScreen> {
  List<Map<String, String>> employees = [
    {'code': 'EMP001', 'name': 'John Doe', 'status': 'Active'},
    {'code': 'EMP002', 'name': 'Jane Smith', 'status': 'Active'},
    {'code': 'EMP003', 'name': 'Bob Johnson', 'status': 'Inactive'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add employee screen
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(employee['name']!),
              subtitle: Text('Code: ${employee['code']}'),
              trailing: Chip(
                label: Text(employee['status']!),
                backgroundColor: employee['status'] == 'Active'
                  ? AppColors.secondary.withValues(alpha: 0.30)
                  : AppColors.vkBackground,
              ),
              onTap: () {
                // TODO: Edit employee
              },
            ),
          );
        },
      ),
    );
  }
}
