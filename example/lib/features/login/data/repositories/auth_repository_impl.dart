import 'package:forge_mvvm/forge_mvvm.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service_impl.dart';

class AuthRepositoryImpl extends AuthRepository {
  AuthRepositoryImpl(this._service);
  final AuthServiceImpl _service;

  @override
  Future<ForgeResult<User>> login(String email, String password) async {
    try {
      final dto = await _service.login(email, password);
      return ForgeResult.success(
        User(id: dto.id, email: dto.email, name: dto.name),
      );
    } on ForgeException catch (e) {
      return ForgeResult.failure(e);
    } on Exception catch (_) {
      return ForgeResult.failure(
        const ForgeNetworkException('Unexpected error: \${e.toString()}'),
      );
    }
  }
}
