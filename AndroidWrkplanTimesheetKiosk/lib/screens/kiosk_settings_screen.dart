import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/shared_preference_helper.dart';
import '../constants/app_colors.dart';

class KioskSettingsScreen extends StatefulWidget {
  const KioskSettingsScreen({super.key});

  @override
  State<KioskSettingsScreen> createState() => _KioskSettingsScreenState();
}

class _KioskSettingsScreenState extends State<KioskSettingsScreen> {
  late TextEditingController _baseUrlCtrl;
  late TextEditingController _latCtrl;
  late TextEditingController _lonCtrl;
  late TextEditingController _radiusCtrl;
  final _prefs = SharedPreferenceHelper();

  @override
  void initState() {
    super.initState();
    _baseUrlCtrl = TextEditingController(text: AppConstants.baseUrl);
    final lat    = _prefs.getOfficeLat();
    final lon    = _prefs.getOfficeLon();
    final radius = _prefs.getPunchRadius();
    _latCtrl    = TextEditingController(text: lat == 0.0 ? '' : lat.toString());
    _lonCtrl    = TextEditingController(text: lon == 0.0 ? '' : lon.toString());
    _radiusCtrl = TextEditingController(text: radius.toString());
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kiosk Unit Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Server Configuration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 12),
            TextField(
              controller: _baseUrlCtrl,
              decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'http://14.99.211.60:9012/',
                  prefixIcon: Icon(Icons.link)),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            const Text('Location-based Punch',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            const Text('Leave blank to disable location check.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: _latCtrl,
              decoration: const InputDecoration(
                  labelText: 'Office Latitude',
                  prefixIcon: Icon(Icons.location_on)),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lonCtrl,
              decoration: const InputDecoration(
                  labelText: 'Office Longitude',
                  prefixIcon: Icon(Icons.location_on)),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _radiusCtrl,
              decoration: const InputDecoration(
                  labelText: 'Allowed Radius (metres)',
                  prefixIcon: Icon(Icons.radar)),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white),
              child: const Text('SAVE SETTINGS',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final url = _baseUrlCtrl.text.trim();
    if (url.isNotEmpty) await AppConstants.saveBaseUrl(url);

    final lat    = double.tryParse(_latCtrl.text.trim()) ?? 0.0;
    final lon    = double.tryParse(_lonCtrl.text.trim()) ?? 0.0;
    final radius = double.tryParse(_radiusCtrl.text.trim()) ?? 200.0;
    await _prefs.saveOfficeLat(lat);
    await _prefs.saveOfficeLon(lon);
    await _prefs.savePunchRadius(radius);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Settings saved')));
    Navigator.of(context).pop();
  }
}
