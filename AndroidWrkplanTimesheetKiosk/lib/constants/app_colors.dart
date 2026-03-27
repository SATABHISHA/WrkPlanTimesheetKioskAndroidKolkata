import 'package:flutter/material.dart';

/// Exact colour palette from satabhisha drawable XMLs and layout files.
class AppColors {
  // ── Main backgrounds ───────────────────────────────────────────────────────
  static const Color darkNavy      = Color(0xFF141E31); // toolbar + body bg
  static const Color cardBg        = Color(0xFF172A46); // layout_custom_btn_reusable_vk1
  static const Color cardStroke    = Color(0xFF232E47); // stroke/secondary card
  static const Color dashCardBg    = Color(0xFF232E47); // layout_home_recognize_vk1 solid
  static const Color dashCardStroke= Color(0xFF394B66); // layout_home_recognize_vk1 stroke
  static const Color appBarLight   = Color(0xFFA5AFCE); // AppBarLayout bg

  // ── Login-specific ─────────────────────────────────────────────────────────
  static const Color loginBgStart  = Color(0xFFD2DFF1); // gradient start
  static const Color loginBgEnd    = Color(0xFFFFFFFF); // gradient end
  static const Color iconBox       = Color(0xFF0A192F); // left icon panel
  static const Color fieldBg       = Color(0xFF3B567E); // rouned_broder_vk1
  static const Color loginBtn      = Color(0xFF0A192F); // login button
  static const Color loginCaption  = Color(0xFF364673); // "KIOSK Admin" title

  // ── Accent / teal ─────────────────────────────────────────────────────────
  static const Color teal          = Color(0xFF55D5BE); // headline area + btn text
  static const Color infoCardBg    = Color(0xFF42AE9B); // layout_background_layer_view_vk1

  // ── Punch buttons ─────────────────────────────────────────────────────────
  static const Color punchIn       = Color(0xFF172A46); // same as reusable btn
  static const Color breakColor    = Color(0xFFE5B445); // layout_custom_break_btn
  static const Color punchOut      = Color(0xFFCF2F2F); // layout_custom_punch_out_btn

  // ── Dialog ────────────────────────────────────────────────────────────────
  static const Color dialogHeader  = Color(0xFF394A68);
  static const Color dialogBody    = Color(0xFF596C8D);
  static const Color dialogText    = Color(0xFFCBD5F5);
  static const Color dialogOk      = Color(0xFF75B253);
  static const Color dialogNo      = Color(0xFFF02B2B);

  // ── Generic ───────────────────────────────────────────────────────────────
  static const Color white         = Color(0xFFFFFFFF);
  static const Color lightCard     = Color(0xFFDDE5FF); // layout_background_layer_vk1

  // ── Backward compat aliases ───────────────────────────────────────────────
  static const Color primary        = darkNavy;
  static const Color primaryVariant = cardBg;
  static const Color secondary      = teal;
  static const Color vkBackground   = lightCard;
  static const Color textDark       = Color(0xFF37474F);
}
