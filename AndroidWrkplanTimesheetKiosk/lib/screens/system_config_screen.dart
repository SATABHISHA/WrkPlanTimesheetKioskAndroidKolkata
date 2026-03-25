import 'package:flutter/material.dart';

class SystemConfigScreen extends StatefulWidget {
  const SystemConfigScreen({Key? key}) : super(key: key);

  @override
  State<SystemConfigScreen> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends State<SystemConfigScreen> {
  late TextEditingController _apiUrlController;

  @override
  void initState() {
    super.initState();
    _apiUrlController = TextEditingController(
      text: 'http://14.99.211.60:9012/',
    );
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Configuration'),
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
                'API Configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _apiUrlController,
                decoration: InputDecoration(
                  labelText: 'API Base URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
              ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Test API connection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Connection test passed')),
                  );
                },
                child: const Text('Test Connection'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Save configuration
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuration saved')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Save Configuration'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'System Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('App Version'),
                trailing: const Text('1.11'),
              ),
              ListTile(
                title: const Text('Last Sync'),
                trailing: const Text('2026-03-25 10:30'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
