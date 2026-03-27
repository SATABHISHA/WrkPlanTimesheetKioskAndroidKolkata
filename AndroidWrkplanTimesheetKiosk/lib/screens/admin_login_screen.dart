import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

/// Mirrors AdminLoginActivity from satabhisha – same layout as employee login
/// but title says "User Login".
const _kBgStart      = Color(0xFFD2DFF1);
const _kBgEnd        = Color(0xFFFFFFFF);
const _kIconBox      = Color(0xFF0A192F);
const _kFieldBg      = Color(0xFF3B567E);
const _kLoginBtn     = Color(0xFF0A192F);
const _kLoginBtnText = Color(0xFF55D5BE);
const _kTitleColor   = Color(0xFF364673);

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  late TextEditingController _usernameCtrl;
  late TextEditingController _passwordCtrl;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _snack('Please fill all fields');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      corpId: '',
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (ok && mounted) {
      Navigator.of(context).pushReplacementNamed('/admin-home');
    } else if (mounted) {
      _snack(auth.errorMessage ?? 'Login failed');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(height: 56, color: Colors.white),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kBgEnd, _kBgStart],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(35, 50, 35, 120),
                    child: Column(
                      children: [
                        // Logo + "User Login"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/kioskapplogo.png',
                                width: 50, height: 50),
                            const SizedBox(width: 8),
                            const Text(
                              'User Login',
                              style: TextStyle(
                                color: _kTitleColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Username
                        _inputRow(
                          controller: _usernameCtrl,
                          hint: 'Username',
                          iconAsset: 'assets/images/usernamenewvk1.png',
                          action: TextInputAction.next,
                        ),
                        const SizedBox(height: 10),

                        // Password
                        _inputRow(
                          controller: _passwordCtrl,
                          hint: 'Password',
                          iconAsset: 'assets/images/passwordnewvk1.png',
                          action: TextInputAction.done,
                          obscure: _obscure,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscure = !_obscure),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                _obscure ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white70, size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login button
                        Consumer<AuthProvider>(
                          builder: (_, auth, __) {
                            return GestureDetector(
                              onTap: auth.isLoading ? null : _handleLogin,
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: _kLoginBtn,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 22, height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2, color: _kLoginBtnText))
                                    : const Text('Login  >',
                                        style: TextStyle(
                                          color: _kLoginBtnText,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600)),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Back link
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Employee Login',
                            style: TextStyle(
                              color: _kTitleColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0, right: 0, bottom: 50,
                    child: SizedBox(
                      height: 50,
                      child: Image.asset('assets/images/kiosklogo.png',
                          fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputRow({
    required TextEditingController controller,
    required String hint,
    required String iconAsset,
    TextInputAction action = TextInputAction.done,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Container(
            width: 50,
            decoration: const BoxDecoration(
              color: _kIconBox,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            alignment: Alignment.center,
            child: Image.asset(iconAsset, width: 24, height: 24,
                color: Colors.white),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _kFieldBg,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: controller,
                obscureText: obscure,
                textInputAction: action,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  suffixIcon: suffixIcon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
