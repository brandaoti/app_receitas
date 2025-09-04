import 'package:app_receitas/utils/exceptions/default_exception.dart';
import 'package:app_receitas/utils/typedef.dart';
import 'package:dart_either/dart_either.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

abstract class IAuthRepository {
  Future<Output<UserProfile>> signInWithPassword({
    required String email,
    required String password,
  });

  Future<Output<AuthResponse>> signUp({
    required String email,
    required String password,
    required String username,
    required String avatarUrl,
  });

  Future<Output<UserProfile>> get currentUser;
}

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthService _service;
  const AuthRepositoryImpl(IAuthService service) : _service = service;

  @override
  Future<Output<UserProfile>> get currentUser async {
    try {
      final user = _service.currentUser;

      final profile = await _service.getUserProfile(user!.id);

      return profile.fold(
        ifLeft: (error) => Left(
          DefaultException(message: 'Failed to fetch user profile: $error'),
        ),
        ifRight: (profileData) async {
          if (profileData == null) {
            return Left(DefaultException(message: 'User profile not found'));
          }

          final userProfile = await _userProfile(
            profileData: profileData,
            userData: user.toJson(),
          );
          return Right(userProfile);
        },
      );
    } on Exception catch (e) {
      return Left(
        DefaultException(message: 'Failed to fetch current user: $e'),
      );
    }
  }

  @override
  Future<Output<UserProfile>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await _service.signInWithPassword(
      email: email,
      password: password,
    );
    return response.fold(
      ifLeft: (error) => Left(error),
      ifRight: (value) async {
        final user = value.user;

        if (user == null) {
          return Left(DefaultException(message: 'User not found'));
        }

        final profileResult = await _service.getUserProfile(user.id);
        return profileResult.fold(
          ifLeft: (error) => Left(
            DefaultException(message: 'Failed to fetch user profile: $error'),
          ),
          ifRight: (profileData) async {
            if (profileData == null) {
              return Left(DefaultException(message: 'User profile not found'));
            }

            final userProfile = await _userProfile(
              profileData: profileData,
              userData: user.toJson(),
            );
            return Right(userProfile);
          },
        );
      },
    );
  }

  Future<UserProfile> _userProfile({
    required PostgrestMap userData,
    required PostgrestMap profileData,
  }) async {
    return UserProfile.fromSupabase(userData, profileData);
  }

  @override
  Future<Output<AuthResponse>> signUp({
    required String email,
    required String password,
    required String username,
    required String avatarUrl,
  }) async {
    try {
      final usernameExists = await _service.fetchProfileByUsername(username);
      if (usernameExists != null) {
        return Left(DefaultException(message: 'Username já registrado'));
      }

      final authResponse = await _service.insertUser(
        email: email,
        password: password,
      );

      final result = authResponse.fold<Output<AuthResponse>>(
        ifLeft: (error) => Left(error),
        ifRight: (value) {
          final user = value.user;
          if (user == null) {
            return Left(DefaultException(message: 'Failed to sign up'));
          }

          _service.insertProfile(
            userId: user.id,
            username: username,
            avatarUrl: avatarUrl,
          );

          return Right(value);
        },
      );

      return result;
    } on DefaultException catch (e) {
      return Left(e);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return Left(
          DefaultException(message: 'E-mail ou username já registrado'),
        );
      }
      return Left(
        DefaultException(message: 'Erro ao registrar usuário: ${e.message}'),
      );
    } on AuthException catch (e) {
      return Left(
        DefaultException(message: 'Erro de autenticação: ${e.message}'),
      );
    } catch (e) {
      return Left(
        DefaultException(message: 'Erro inesperado ao registrar usuário: $e'),
      );
    }
  }
}
