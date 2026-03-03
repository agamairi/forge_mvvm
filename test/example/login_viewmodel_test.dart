import 'package:flutter_test/flutter_test.dart';
import 'package:forge_mvvm/forge_mvvm.dart';

// These imports reference the example app's source files directly.
// In a real project these would be package: imports.
import '../../example/lib/features/login/domain/models/user.dart'; // ignore: avoid_relative_lib_imports
import '../../example/lib/features/login/domain/repositories/auth_repository.dart'; // ignore: avoid_relative_lib_imports
import '../../example/lib/features/login/ui/login_viewmodel.dart'; // ignore: avoid_relative_lib_imports

class _MockAuthRepository extends ForgeMockRepository
    implements AuthRepository {
  ForgeResult<User>? nextResult;

  @override
  Future<ForgeResult<User>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return nextResult ??
        ForgeResult.success(
          const User(id: '1', email: 'test@forge.dev', name: 'Test User'),
        );
  }
}

void main() {
  late _MockAuthRepository mockRepo;
  late LoginViewModel sut;

  setUp(() {
    mockRepo = _MockAuthRepository();
    sut = LoginViewModel(mockRepo);
    sut.onInit();
  });

  tearDown(() => sut.dispose());

  group('LoginViewModel — initial state', () {
    test('starts with empty fields and no user', () {
      expect(sut.email, isEmpty);
      expect(sut.password, isEmpty);
      expect(sut.currentUser, isNull);
      expect(sut.isLoggedIn, isFalse);
    });
  });

  group('LoginViewModel — field setters', () {
    test('setEmail updates email and notifies', () {
      int count = 0;
      sut.addListener(() => count++);
      sut.setEmail('a@b.com');
      expect(sut.email, equals('a@b.com'));
      expect(count, equals(1));
    });

    test('setPassword updates password and notifies', () {
      int count = 0;
      sut.addListener(() => count++);
      sut.setPassword('secret');
      expect(sut.password, equals('secret'));
      expect(count, equals(1));
    });
  });

  group('LoginViewModel — login()', () {
    test('sets isLoading during login', () async {
      sut.setEmail('test@forge.dev');
      sut.setPassword('password');
      bool wasLoading = false;
      sut.addListener(() {
        if (sut.isLoading) wasLoading = true;
      });
      await sut.login();
      expect(wasLoading, isTrue);
      expect(sut.isLoading, isFalse);
    });

    test('sets currentUser on success', () async {
      sut.setEmail('test@forge.dev');
      sut.setPassword('password');
      await sut.login();
      expect(sut.isLoggedIn, isTrue);
      expect(sut.currentUser!.email, equals('test@forge.dev'));
    });

    test('sets errorMessage on failure', () async {
      mockRepo.nextResult = ForgeResult.failure(
        const ForgeNetworkException('Invalid credentials', code: '401'),
      );
      sut.setEmail('bad@user.com');
      sut.setPassword('wrong');
      await sut.login();
      expect(sut.isLoggedIn, isFalse);
      expect(sut.errorMessage, isNotNull);
    });
  });

  group('LoginViewModel — logout()', () {
    test('clears user and fields after logout', () async {
      sut.setEmail('test@forge.dev');
      sut.setPassword('password');
      await sut.login();
      expect(sut.isLoggedIn, isTrue);
      sut.logout();
      expect(sut.isLoggedIn, isFalse);
      expect(sut.email, isEmpty);
      expect(sut.password, isEmpty);
    });
  });
}
