import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';

abstract class IAuthViewModel {
  bool get obscurePassword;
  bool get isSubmitting;
  bool get isLoginMode;

  String get errorMessage;

  String? validateEmail(String? value);
  String? validatePassword(String? value);
  String? validateConfirmPassword(String? value);
  String? validateUsername(String? value);
  String? validateAvatarUrl(String? value);

  void toggleObscurePassword();
  Future<void> submit();
  void toggleMode();
}

class AuthViewModel extends GetxController implements IAuthViewModel {
  AuthViewModel(IAuthRepository repository) : _repository = repository;

  final IAuthRepository _repository;
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final avatarUrlController = TextEditingController();

  final _obscurePassword = true.obs;
  final _isSubmitting = false.obs;
  final _isLoginMode = true.obs;
  final _errorMessage = ''.obs;

  @override
  bool get obscurePassword => _obscurePassword.value;
  @override
  bool get isSubmitting => _isSubmitting.value;
  @override
  bool get isLoginMode => _isLoginMode.value;
  @override
  String get errorMessage => _errorMessage.value;

  @override
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Informe o e-mail';
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    ).hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  @override
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe a senha';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Precisa de letra minúscula';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Precisa de letra maiúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Precisa de número';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/;]').hasMatch(value)) {
      return 'Precisa de caractere especial';
    }
    return null;
  }

  @override
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirme a senha';
    if (value != passwordController.text) return 'As senhas não coincidem';
    return null;
  }

  @override
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Informe o nome de usuário';
    if (value.length < 3) return 'Mínimo 3 caracteres';
    return null;
  }

  @override
  String? validateAvatarUrl(String? value) {
    if (value == null || value.isEmpty) return 'Informe a URL do avatar';
    if (!RegExp(
      r'^(https?:\/\/)?([\w-]+\.)+[\w-]+(\/[\w- ./?%&=]*)?$',
    ).hasMatch(value)) {
      return 'URL inválida';
    }
    return null;
  }

  @override
  void toggleObscurePassword() =>
      _obscurePassword.value = !_obscurePassword.value;

  @override
  Future<void> submit() async {
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) return;

    _isSubmitting.value = true;

    try {
      if (isLoginMode) {
        await login();
      } else {
        await register();
      }
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  void toggleMode() {
    _isLoginMode.value = !_isLoginMode.value;
    _isSubmitting.value = false;
    _clearFields();
    _obscurePassword.value = true;

    update();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    avatarUrlController.dispose();
    super.onClose();
  }

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    usernameController.clear();
    avatarUrlController.clear();
  }

  Future<void> register() async {
    final response = await _repository.signUp(
      email: emailController.text,
      password: passwordController.text,
      username: usernameController.text,
      avatarUrl: avatarUrlController.text,
    );
    response.fold(
      ifLeft: (error) {
        _errorMessage.value = error.message;
      },
      ifRight: (value) {
        _errorMessage.value =
            'E-mail de confirmação enviado. Verifique sua caixa de entrada';
        _isLoginMode.value = true;

        _clearFields();
      },
    );
  }

  Future<void> login() async {
    _errorMessage.value = '';

    final response = await _repository.signInWithPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    return response.fold(
      ifLeft: (error) {
        _errorMessage.value = error.message;
      },
      ifRight: (value) {
        _clearFields();
        return;
      },
    );
  }
}
