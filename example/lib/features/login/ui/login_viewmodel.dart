import 'package:forge_mvvm/forge_mvvm.dart';
import '../domain/models/user.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_params.dart';
import '../domain/usecases/login_usecase.dart';

class LoginViewModel extends ForgeViewModel {
  LoginViewModel(AuthRepository repository)
      : _loginUseCase = LoginUseCase(repository);

  final LoginUseCase _loginUseCase;

  String _email = '';
  String _password = '';
  User? _currentUser;

  String get email => _email;
  String get password => _password;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  Future<void> login() async {
    await runBusyAction(() async {
      final result = await _loginUseCase.execute(
        LoginParams(email: _email, password: _password),
      );
      result.when(
        success: (user) {
          _currentUser = user;
          clearError();
        },
        failure: (e) => setError(e.toString()),
      );
    });
  }

  void logout() {
    _currentUser = null;
    _email = '';
    _password = '';
    notifyListeners();
  }
}
