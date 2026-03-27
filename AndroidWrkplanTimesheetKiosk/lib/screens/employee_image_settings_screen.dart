import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../models/employee_model.dart';
import '../constants/app_colors.dart';

/// Mirrors EmployeeImageSettingsActivity from satabhisha.
/// Shows employee list from ListFaces API; allows enrol/remove face images.
class EmployeeImageSettingsScreen extends StatefulWidget {
  const EmployeeImageSettingsScreen({super.key});
  @override
  State<EmployeeImageSettingsScreen> createState() =>
      _EmployeeImageSettingsScreenState();
}

class _EmployeeImageSettingsScreenState
    extends State<EmployeeImageSettingsScreen> {
  final _api       = ApiService();
  final _searchCtrl = TextEditingController();

  List<EmployeeImageSettings> _allEmployees      = [];
  List<EmployeeImageSettings> _filteredEmployees = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    _searchCtrl.addListener(() => _filter(_searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      final json = await _api.listFaces(corpId: auth.user!.corpID!);
      final responseObj = json['response'] as Map<String, dynamic>? ?? {};
      if (responseObj['status']?.toString() == 'true') {
        final raw  = json['employees'];
        final list = (raw is List ? raw : (raw != null ? [raw] : []))
            .map((e) => EmployeeImageSettings.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
        setState(() {
          _allEmployees      = list;
          _filteredEmployees = list;
          _loading           = false;
        });
      } else {
        setState(() => _loading = false);
        _showSnack('No employee data');
      }
    } catch (_) {
      setState(() => _loading = false);
      _showSnack('Could not connect to server');
    }
  }

  void _filter(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filteredEmployees = q.isEmpty
          ? _allEmployees
          : _allEmployees
              .where((e) => e.fullName.toLowerCase().contains(q))
              .toList();
    });
  }

  // Mirrors EmployeeImageSettingsAdapter enroll logic
  void _onEnrollRemove(EmployeeImageSettings emp) async {
    if (emp.awsAction == 'enroll') {
      // Show instructions dialog then open camera (mirrors Android alert)
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text('Enroll face for ${emp.fullName}?'),
          content: const Text(
              '1. Head centred in frame\n'
              '2. Look directly at camera\n'
              '3. No hair across face/eyes\n'
              '4. Do not tilt head\n'
              '5. Avoid dark background'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
          ],
        ),
      );
      if (confirm != true) return;
      _captureAndEnroll(emp);
    } else {
      // Delete image
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Remove Image'),
          content: Text('Remove face image for ${emp.fullName}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.punchOut),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      _deleteImage(emp);
    }
  }

  Future<void> _captureAndEnroll(EmployeeImageSettings emp) async {
    final picker = ImagePicker();
    final image  = await picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if (image == null) return;

    final bytes     = await File(image.path).readAsBytes();
    final base64Str = base64Encode(bytes);
    final auth      = context.read<AuthProvider>();

    _showLoading('Enrolling image…');
    try {
      await _api.indexFaces(
        corpId:     auth.user!.corpID!,
        employeeId: emp.idPerson ?? '',
        imageBase64: base64Str,
      );
      if (mounted) Navigator.of(context).pop();
      _loadData();
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      _showSnack('Could not connect to server');
    }
  }

  Future<void> _deleteImage(EmployeeImageSettings emp) async {
    final auth = context.read<AuthProvider>();
    _showLoading('Removing image…');
    try {
      await _api.deleteFace(
          corpId: auth.user!.corpID!, employeeId: emp.idPerson ?? '');
      if (mounted) Navigator.of(context).pop();
      _loadData();
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      _showSnack('Could not connect to server');
    }
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
      ])),
    );
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Image Settings')),
      body: Column(
        children: [
          // Search field (mirrors ed_search in EmployeeImageSettingsActivity)
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search employee',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty
                    ? const Center(child: Text('No employees found'))
                    : ListView.builder(
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (_, i) {
                          final emp      = _filteredEmployees[i];
                          final hasImage = emp.hasImage;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: hasImage
                                    ? AppColors.punchIn.withAlpha(30)
                                    : AppColors.vkBackground,
                                child: Icon(
                                  hasImage ? Icons.check_circle : Icons.image_not_supported,
                                  color: hasImage ? AppColors.punchIn : Colors.grey,
                                ),
                              ),
                              title: Text(emp.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                  hasImage ? 'Image Enrolled' : 'No Image',
                                  style: TextStyle(
                                      color: hasImage ? AppColors.punchIn : Colors.grey)),
                              trailing: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: hasImage
                                      ? AppColors.punchOut.withAlpha(20)
                                      : AppColors.punchIn.withAlpha(20),
                                ),
                                onPressed: () => _onEnrollRemove(emp),
                                child: Text(
                                    hasImage ? 'Remove\nImage' : 'Enroll\nImage',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: hasImage
                                            ? AppColors.punchOut
                                            : AppColors.punchIn,
                                        fontSize: 12)),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
