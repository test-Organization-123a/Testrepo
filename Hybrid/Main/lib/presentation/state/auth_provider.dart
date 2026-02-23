import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/locator.dart' as di;

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = di.Locator.authRepository;
  User? _user;
  bool _restoring = true;

  AuthProvider() {
    _restore();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isRestoring => _restoring;
  bool get isAdmin => _user?.role == 'ADMIN';

  Future<void> _restore() async {
    _user = await _repo.restoreSession();
    _restoring = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final auth = await _repo.login(email, password);
    _user = auth.user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }
}
