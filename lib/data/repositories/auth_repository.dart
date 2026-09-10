import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../supabase_client.dart';

const _emailDomain = '@mkwstats.local';

class AuthRepository {
  Session? get currentSession => supabase.auth.currentSession;

  Stream<AuthState> get onAuthStateChange => supabase.auth.onAuthStateChange;

  Future<bool> isUsernameTaken(String username) async {
    final result = await supabase.rpc(
      'is_username_taken',
      params: {'check_username': username},
    );
    return result as bool;
  }

  Future<void> signUp({
    required String username,
    required String password,
  }) async {
    await supabase.auth.signUp(
      email: '$username$_emailDomain',
      password: password,
      data: {'username': username},
    );
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: '$username$_emailDomain',
      password: password,
    );
  }

  Future<void> signOut() => supabase.auth.signOut();

  Future<Profile> fetchCurrentProfile() async {
    final userId = currentSession!.user.id;
    final json = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return Profile.fromJson(json);
  }
}
