import 'package:forge_mvvm/forge_mvvm.dart';
import 'auth_service.dart';

class AuthServiceImpl extends AuthService {
  @override
  Future<UserDto> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'test@forge.dev' && password == 'password') {
      return UserDto(id: 'usr_01', email: email, name: 'Forge Developer');
    }
    throw const ForgeNetworkException('Invalid credentials', code: '401');
  }
}
