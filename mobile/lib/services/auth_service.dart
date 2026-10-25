import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const redirectUrl = 'skinx://auth/callback';
  static bool _initialized = false;
  static StreamSubscription<AuthState>? _subscription;
  static final passwordRecoveryPending = ValueNotifier<bool>(false);

  static bool get configured => _initialized;
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (url.isEmpty || publishableKey.isEmpty) return;
    try {
      await Supabase.initialize(url: url, anonKey: publishableKey);
      _initialized = true;
      _subscription ??= client.auth.onAuthStateChange.listen((state) {
        if (state.event == AuthChangeEvent.passwordRecovery) {
          passwordRecoveryPending.value = true;
        }
      }, onError: (Object error, StackTrace trace) {});
    } catch (_) {
      _initialized = false;
    }
  }

  static User? get user => configured ? client.auth.currentUser : null;
  static String get ownerId => user?.id ?? 'offline_guest';
  static String? get accessToken => configured ? client.auth.currentSession?.accessToken : null;

  static Future<void> signIn(String email, String password) async {
    if (!configured) throw StateError('Online accounts are not configured.');
    await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<bool> signUp(String name, String email, String password, String accountType) async {
    if (!configured) throw StateError('Online accounts are not configured.');
    final response = await client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: redirectUrl,
      data: {'full_name': name, 'account_type': accountType},
    );
    return response.session != null;
  }

  static Future<void> requestPasswordReset(String email) async {
    if (!configured) throw StateError('Online accounts are not configured.');
    await client.auth.resetPasswordForEmail(email, redirectTo: redirectUrl);
  }

  static Future<void> updatePassword(String newPassword) async {
    if (!configured || user == null) throw StateError('No signed-in session.');
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    if (user == null) return null;
    final data = await client.from('profiles').select('id, full_name, account_type').eq('id', user!.id).maybeSingle();
    return data;
  }

  static Future<void> updateAccountType(String type) async {
    if (user == null) return;
    await client.from('profiles').update({'account_type': type}).eq('id', user!.id);
    await client.auth.updateUser(UserAttributes(data: {'account_type': type}));
  }

  static Future<void> signOut() async {
    if (configured && user != null) await client.auth.signOut();
  }
}
