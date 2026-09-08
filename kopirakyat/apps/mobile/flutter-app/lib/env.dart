/// Supabase project credentials, injected at build/run time with
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
/// (see the README for a `flutter run` example). These are public,
/// row-level-security-gated anon keys — safe to compile into the client.
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const posBaseUrl = String.fromEnvironment('POS_BASE_URL', defaultValue: '');
  static const posApiKey = String.fromEnvironment('POS_API_KEY', defaultValue: '');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
