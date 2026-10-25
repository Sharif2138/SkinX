import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static bool _initialized = false;
  static bool get configured => _initialized;

  static Future<void> initialize() async {
    if (url.isEmpty || publishableKey.isEmpty) return;
    try {
      await Supabase.initialize(url: url, anonKey: publishableKey);
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  static User? get user => configured ? Supabase.instance.client.auth.currentUser : null;
  static String? get accessToken => configured ? Supabase.instance.client.auth.currentSession?.accessToken : null;
  static String get ownerId => user?.id ?? 'offline_guest';

  static Future<void> signIn(String email, String password) async {
    if (!configured) throw StateError('Accounts are not configured yet. Use offline mode.');
    await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<bool> signUp(String name, String email, String password, String role) async {
    if (!configured) throw StateError('Accounts are not configured yet. Use offline mode.');
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'role': role},
    );
    return response.session != null;
  }

  static Future<void> signOut() async {
    if (configured && user != null) {
      await Supabase.instance.client.auth.signOut();
    }
  }
}
