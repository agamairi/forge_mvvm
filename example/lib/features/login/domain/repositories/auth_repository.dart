import 'package:forge_mvvm/forge_mvvm.dart';
import '../models/user.dart';

abstract class AuthRepository extends ForgeRepository {
  Future<ForgeResult<User>> login(String email, String password);
}
