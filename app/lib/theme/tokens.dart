import 'package:flutter/material.dart';

/// Design tokens ported 1:1 from the Claude Design prototype
/// (`project/Kopi Rakyat App.dc.html`) — colors, radius ladder and
/// spacing scale. Keep this file as the single source of truth instead
/// of hard-coding hex values or px numbers in widgets.
class AppColors {
  AppColors._();

  static const brand = Color(0xFFEC3013);
  static const brandPressed = Color(0xFFDD2B0F);
  static const brandAlt = Color(0xFFC11414);

  static const ink = Color(0xFF201E1D);
  static const panel = Color(0xFF141312);

  static const surface = Color(0xFFEEEDEB);
  static const card = Color(0xFFFBFBFA);
  static const muted = Color(0xFFF6F5F4);
  static const chrome = Color(0xFFF1F0EE);
  static const hover = Color(0xFFE8E7E4);
  static const placeholder = Color(0xFFE2E1DE);

  static const gold = Color(0xFFF2C14B);
  static const goldText = Color(0xFF8A6A26);
  static const goldTextDeep = Color(0xFF7A5A12);
  static const voucherRed = Color(0xFFAE1800);
  static const voucherTint = Color(0xFFF7ECEB);
  static const green = Color(0xFF137A3F);

  static Color inkAlpha(double opacity) => ink.withValues(alpha: opacity);
  static const divider = Color(0x33201E1D); // rgba(32,30,29,.2)
  static const hairline = Color(0x1F201E1D); // rgba(32,30,29,.12)
  static const border = Color(0x29201E1D); // rgba(32,30,29,.16)
}

class AppRadius {
  AppRadius._();

  static const control = 14.0;
  static const card = 18.0;
  static const cardLarge = 20.0;
  static const pill = 999.0;
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}
