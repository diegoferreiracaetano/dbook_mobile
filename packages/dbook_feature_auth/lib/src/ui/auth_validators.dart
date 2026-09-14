import 'package:flutter/widgets.dart';

/// Validação de formulário compartilhada entre login e registro — checagem
/// só de formato/local; o backend é quem valida credencial/duplicidade de
/// verdade.
abstract final class AuthValidators {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite seu nome';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite seu e-mail';
    }
    if (!_emailPattern.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite sua senha';
    }
    if (value.length < 6) {
      return 'A senha precisa ter pelo menos 6 caracteres';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(
    TextEditingController passwordController,
  ) {
    return (value) {
      if (value != passwordController.text) {
        return 'As senhas não coincidem';
      }
      return null;
    };
  }
}
