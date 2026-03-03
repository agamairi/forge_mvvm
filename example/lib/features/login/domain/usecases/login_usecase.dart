import 'package:forge_mvvm/forge_mvvm.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'login_params.dart';

class LoginUseCase extends ForgeUseCase<LoginParams, ForgeResult<User>> {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<ForgeResult<User>> execute(LoginParams params) =>
      _repository.login(params.email, params.password);
}
