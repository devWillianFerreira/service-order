import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _carregando = false;
  String? _errorMessage;

  bool get carregando => _carregando;

  String? get errorMessage => _errorMessage;

  bool get usuarioAutenticado => _authService.currentUser != null;

  Future<bool> entrar({required String email, required String senha}) async {
    _carregando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email: email.trim(), password: senha);

      return true;
    } catch (e) {
      _errorMessage = _mensagemErro(e);

      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> sair() async {
    _carregando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      _errorMessage = 'Não foi possível sair da conta.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  void limparErro() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mensagemErro(Object erro) {
    return 'Não foi possível realizar o login. Verifique seu e-mail e senha.';
  }
}
