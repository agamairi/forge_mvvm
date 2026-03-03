import 'package:forge_mvvm/forge_mvvm.dart';

class UserDto {
  const UserDto({required this.id, required this.email, required this.name});
  final String id;
  final String email;
  final String name;
}

abstract class AuthService extends ForgeService {
  Future<UserDto> login(String email, String password);
}
