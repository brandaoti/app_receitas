import 'package:app_receitas/utils/exceptions/default_exception.dart';
import 'package:app_receitas/utils/typedef.dart';
import 'package:dart_either/dart_either.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthService {
  User? get currentUser;
  Stream<AuthState> get authStateChanges;

  Future<Output<AuthResponse>> signInWithPassword({
    required String email,
    required String password,
  });

  // Future<AuthResponse> signUp({
  //   required String email,
  //   required String password,
  // required String avatarUrl,
  // required String username,
  // });

  Future<Output<AuthResponse>> insertUser({
    required String email,
    required String password,
  });
  Future<void> insertProfile({
    required String userId,
    required String username,
    required String avatarUrl,
  });
  Future<void> signOut();
  Future<Output<Map<String, dynamic>?>> getUserProfile(String userId);
  Future<PostgrestMap?> fetchProfileByUsername(String username);
}

class AuthServiceImpl implements IAuthService {
  final SupabaseClient _client;

  const AuthServiceImpl(SupabaseClient client) : _client = client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<Output<AuthResponse>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return Right(response);
    } on AuthException catch (e) {
      switch (e.message) {
        case 'Invalid login credentials':
          return Left(
            DefaultException(
              message: 'Usuário não cadastrado ou credenciais inválidas',
            ),
          );
        case 'Email not confirmed':
          return Left(DefaultException(message: 'E-mail não confirmado'));
        default:
          return Left(DefaultException(message: 'Erro ao fazer login'));
      }
    }
  }

  @override
  Future<Output<AuthResponse>> insertUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return Right(response);
    } on AuthException catch (e) {
      switch (e.message) {
        case 'Email not confirmed':
          return Left(
            DefaultException(
              message: 'E-mail não confirmado. Verifique sua caixa de entrada',
            ),
          );
        default:
          return Left(
            DefaultException(message: 'Erro ao fazer cadastro: ${e.message}'),
          );
      }
    }
  }

  @override
  Future<void> insertProfile({
    required String userId,
    required String username,
    required String avatarUrl,
  }) async {
    return await _client.from('profiles').insert({
      'id': userId,
      'username': username,
      'avatar_url': avatarUrl,
    });
  }

  @override
  Future<PostgrestMap?> fetchProfileByUsername(String username) async {
    return await _client
        .from('profiles')
        .select()
        .eq('username', username)
        .maybeSingle();
  }

  @override
  Future<Output<Map<String, dynamic>?>> getUserProfile(String userId) async {
    try {
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return Right(profile);
    } catch (e) {
      return Left(DefaultException(message: 'Erro ao carregar profile'));
    }
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut(scope: SignOutScope.global);
  }
}
