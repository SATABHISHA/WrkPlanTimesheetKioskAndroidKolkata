import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/shared_preference_helper.dart';

// ── Exact hex colours from satabhisha drawable XMLs ──────────────────────────
const _kBgStart      = Color(0xFFD2DFF1); // activity_login_background_shape startColor
const _kBgEnd        = Color(0xFFFFFFFF); // activity_login_background_shape endColor
const _kIconBox      = Color(0xFF0A192F); // rouned_broder__admin_login_leftside_logo_background_vk1
const _kFieldBg      = Color(0xFF3B567E); // rouned_broder_vk1
const _kLoginBtn     = Color(0xFF0A192F); // rouned_broder_login_vk1
const _kLoginBtnText = Color(0xFF55D5BE); // tv_login textColor
const _kTitleColor   = Color(0xFF364673); // KIOSK Admin textColor

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
  final _prefs  = SharedPreferenceHelper();

  @override
  void initState() {
    super.initState();
    _corpIdCtrl   = TextEditingController(text: _prefs.getCorpIdAutofill());
    _usernameCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _corpIdCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Validation + login ─────────────────────────────────────────────────────

  void _handleLogin() async {
    if (_corpIdCtrl.text.trim().isEmpty) {
      _snack('Userid is required');
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── White toolbar (android:background="#ffffff") ──────────────────
          SafeArea(
            bottom: false,
            child: Container(height: 56, color: Colors.white),
          ),

          // ── Body with gradient #D2DFF1 → #FFFFFF (angle 90 = bottom→top) ─
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
                  // ── Scrollable form (margin 35dp each side) ──────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(35, 50, 35, 120),
                    child: Column(
                      children: [
                        // ── Logo + "KIOSK Admin" ───────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/kioskapplogo.png',
                                width: 50, height: 50),
                            const SizedBox(width: 8),
                            const Text(
                              'KIOSK Admin',
                              style: TextStyle(
                                color: _kTitleColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Corp ID ────────────────────────────────────────
                        _inputRow(
                          controller: _corpIdCtrl,
                          hint: 'Corporate ID',
                          iconAsset: 'assets/images/orgvk1.png',
                          action: TextInputAction.next,
                        ),
                        const SizedBox(height: 10),

                        // ── Username ───────────────────────────────────────
                        _inputRow(
                          controller: _usernameCtrl,
                          hint: 'Username',
                          iconAsset: 'assets/images/usernamenewvk1.png',
                          action: TextInputAction.next,
                        ),
                        const SizedBox(height: 10),

                        // ── Password ───────────────────────────────────────
                        _inputRow(
                          controller: _passwordCtrl,
                          hint: 'Password',
                          iconAsset: 'assets/images/passwordnewvk1.png',
                          action: TextInputAction.done,
                          obscure: _obscure,
                          suffixIcon: GestureDetector(
                            onTap: () =>
                                setState(() => _obscure = !_obscure),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                _obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Login button (#0A192F, 55dp, rounded 10) ───────
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
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _kLoginBtnText,
                                        ),
                                      )
                                    : const Text(
                                        'Login  >',
                                        style: TextStyle(
                                          color: _kLoginBtnText,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // ── Admin Login link ───────────────────────────────
                        GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushNamed('/admin-login'),
                          child: const Text(
                            'Admin Login',
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

                  // ── Bottom kiosk logo (50dp height, 50dp from bottom) ────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 50,
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

  // ── Single input row: icon box (left-rounded) + text field (right-rounded) ─

  Widget _inputRow({
    required TextEditingController controller,
    required String hint,
    required String iconAsset,
    TextInputAction action = TextInputAction.done,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 50, // android:layout_height="50dp"
      child: Row(
        children: [
          // ── Icon box (#0A192F, left-rounded 10dp) ────────────────────────
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
            child: Image.asset(iconAsset, width: 21, height: 21),
          ),

          // ── Text field (#3B567E, right-rounded 10dp, white text) ─────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _kFieldBg,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      obscureText: obscure,
                      textInputAction: action,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 14),
                      ),
                    ),
                  ),
                  if (suffixIcon != null) suffixIcon,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
