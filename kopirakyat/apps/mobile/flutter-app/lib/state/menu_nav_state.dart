import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One-shot "open Menu on this tab" request, set by callers (Home's promo
/// banner, tapping a category) and consumed+cleared by MenuScreen on init —
/// mirrors the prototype's `goMenuSignature: () => this.go('menu', {menuTab:'Coffee', ...})`.
final menuInitialTabProvider = StateProvider<String?>((ref) => null);
