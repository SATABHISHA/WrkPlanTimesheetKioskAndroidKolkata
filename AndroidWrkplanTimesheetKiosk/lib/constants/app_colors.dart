import 'package:flutter/material.dart';

/// WrkPlan Kiosk v2 – high-contrast light-mode palette.
class AppColors {
  // ── Core palette (design spec) ─────────────────────────────────────────────
  static const Color primary       = Color(0xFF036773);
  static const Color secondary     = Color(0xFF81B1AE);
  static const Color textColor     = Color(0xFF000000);
  static const Color background    = Color(0xFFFFFFFF);
  static const Color white         = Color(0xFFFFFFFF);

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const Color cardBg        = Color(0xFFFFFFFF);
  static const Color cardStroke    = Color(0xFFE0E0E0);
  static const Color fieldBg       = Color(0xFFF5F5F5);

  // ── Punch buttons ─────────────────────────────────────────────────────────
  static const Color punchIn       = Color(0xFF036773);
  static const Color breakColor    = Color(0xFF036773);
  static const Color punchOut      = Color(0xFFCF2F2F);

  // ── Dialog ────────────────────────────────────────────────────────────────
  static const Color dialogHeader  = Color(0xFF036773);
  static const Color dialogBody    = Color(0xFFF5F5F5);
  static const Color dialogText    = Color(0xFF000000);
  static const Color dialogOk      = Color(0xFF036773);
  static const Color dialogNo      = Color(0xFFCF2F2F);

  // ── Backward-compat aliases ───────────────────────────────────────────────
  static const Color darkNavy       = background;
  static const Color dashCardBg     = background;
  static const Color dashCardStroke = cardStroke;
  static const Color appBarLight    = background;
  static const Color teal           = primary;
  static const Color infoCardBg     = Color(0xFFF8F8F8);
  static const Color primaryVariant = primary;
  static const Color vkBackground   = fieldBg;
  static const Color lightCard      = fieldBg;
  static const Color textDark       = textColor;

  // ── Login-specific aliases ────────────────────────────────────────────────
  static const Color loginBgStart   = background;
  static const Color loginBgEnd     = background;
  static const Color iconBox        = primary;
  static const Color loginBtn       = primary;
  static const Color loginCaption   = primary;
}
