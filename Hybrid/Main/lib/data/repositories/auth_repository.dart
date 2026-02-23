import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../../data/models/user.dart';
import '../../core/locator.dart' as di;

class AuthRepository {
  final ApiService _api = di.Locator.api;

  AuthRepository();

  Future<AuthResult> login(String email, String password) async {
    final data = await _api.post('auth/login', {
      'email': email,
      'password': password,
    });
    final auth = AuthResult.fromJson(data as Map<String, dynamic>);
    _api.setAuthToken(auth.token);
    await TokenStorage.saveAuth(auth);
    return auth;
  }

  Future<void> logout() async {
    _api.setAuthToken(null);
    await TokenStorage.clear();
  }

  /// Restore token + user on app start
  Future<User?> restoreSession() async {
    final token = await TokenStorage.loadToken();
    final user  = await TokenStorage.loadUser();
    if (token != null) _api.setAuthToken(token);
    return user;
  }
}
