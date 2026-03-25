import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class EmployeeImageSettingsScreen extends StatefulWidget {
  const EmployeeImageSettingsScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeImageSettingsScreen> createState() =>
      _EmployeeImageSettingsScreenState();
}

class _EmployeeImageSettingsScreenState
    extends State<EmployeeImageSettingsScreen> {
  List<Map<String, String>> employeeImages = [
    {'code': 'EMP001', 'name': 'John Doe', 'uploaded': 'Yes'},
    {'code': 'EMP002', 'name': 'Jane Smith', 'uploaded': 'Yes'},
    {'code': 'EMP003', 'name': 'Bob Johnson', 'uploaded': 'No'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Image Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () {
              // TODO: Upload images
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: employeeImages.length,
        itemBuilder: (context, index) {
          final employee = employeeImages[index];
          final isUploaded = employee['uploaded'] == 'Yes';
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.secondary.withValues(alpha: 0.30)
                      : AppColors.vkBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle : Icons.image,
                  color: isUploaded
                      ? AppColors.secondaryVariant
                      : AppColors.primaryVariant,
                ),
              ),
              title: Text(employee['name']!),
              subtitle: Text('Code: ${employee['code']}'),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Upload image for this employee
                },
                child: const Text('Upload'),
              ),
            ),
          );
        },
      ),
    );
  }
}
