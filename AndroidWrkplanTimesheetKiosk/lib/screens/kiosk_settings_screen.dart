import 'package:flutter/material.dart';

class KioskSettingsScreen extends StatefulWidget {
  const KioskSettingsScreen({Key? key}) : super(key: key);

  @override
  State<KioskSettingsScreen> createState() => _KioskSettingsScreenState();
}

class _KioskSettingsScreenState extends State<KioskSettingsScreen> {
  late TextEditingController _kioskIdController;
  late TextEditingController _kioskNameController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _kioskIdController = TextEditingController();
    _kioskNameController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _kioskIdController.dispose();
    _kioskNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiosk Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Kiosk Unit Configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _kioskIdController,
                decoration: InputDecoration(
                  labelText: 'Kiosk ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _kioskNameController,
                decoration: InputDecoration(
                  labelText: 'Kiosk Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Save settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
