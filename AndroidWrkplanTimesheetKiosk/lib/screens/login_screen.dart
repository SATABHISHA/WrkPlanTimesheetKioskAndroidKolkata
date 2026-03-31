import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/shared_preference_helper.dart';
import '../constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _corpIdCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _passwordCtrl;
  bool _obscure = true;
  bool _rememberMe = false;
  final _prefs  = SharedPreferenceHelper();

  @override
  void initState() {
    super.initState();
    _corpIdCtrl   = TextEditingController(text: _prefs.getCorpIdAutofill());
    _rememberMe   = _prefs.getRememberMe();
    _usernameCtrl = TextEditingController(
        text: _rememberMe ? _prefs.getRememberedUsername() : '');
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _corpIdCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_corpIdCtrl.text.trim().isEmpty) {
      _snack('Corporate ID is required');
      return;
    }
    if (_usernameCtrl.text.trim().isEmpty) {
      _snack('Username is required');
      return;
    }
    if (_passwordCtrl.text.isEmpty) {
      _snack('Password is required');
      return;
    }

    final auth = context.read<AuthProvider>();
    // Save corpId for future autofill
    _prefs.saveCorpIdAutofill(_corpIdCtrl.text.trim());
    // Save remember me preference
    _prefs.saveRememberMe(_rememberMe);
    if (_rememberMe) {
      _prefs.saveRememberedUsername(_usernameCtrl.text.trim());
    } else {
      _prefs.saveRememberedUsername('');
    }

    final ok = await auth.login(
      corpId:   _corpIdCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (ok && mounted) {
      Navigator.of(context).pushReplacementNamed('/recognition-option');
    } else if (mounted) {
      _snack(auth.errorMessage ?? 'Login failed');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── WRKPLAN logo ────────────────────────────────────
                  Center(
                    child: Image.asset(
                      'assets/images/KioskLogoV1.png',
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Corporate ID field ────────────────────────────────
                  _buildField(
                    controller: _corpIdCtrl,
                    label: 'Corporate ID',
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // ── Username field ────────────────────────────────────
                  _buildField(
                    controller: _usernameCtrl,
                    label: 'Username',
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // ── Password field ────────────────────────────────────
                  _buildField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    action: TextInputAction.done,
                    obscure: _obscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Remember Me checkbox ──────────────────────────────
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Text(
                          'Remember Me',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Login button ──────────────────────────────────────
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Text(
                                  'Login  >',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputAction action = TextInputAction.done,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      style: const TextStyle(color: AppColors.textColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
