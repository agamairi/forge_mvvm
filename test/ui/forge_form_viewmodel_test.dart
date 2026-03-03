import 'package:flutter_test/flutter_test.dart';
import 'package:forge_mvvm/forge_mvvm.dart';

class _SignUpVM extends ForgeFormViewModel {
  String email = '';
  String password = '';

  @override
  bool validateAll() {
    if (email.isEmpty) {
      setFieldError('email', 'Email is required');
    } else if (!email.contains('@')) {
      setFieldError('email', 'Enter a valid email');
    } else {
      setFieldError('email', null);
    }

    if (password.length < 6) {
      setFieldError('password', 'Min 6 characters');
    } else {
      setFieldError('password', null);
    }

    return isValid;
  }
}

void main() {
  group('ForgeFormViewModel', () {
    late _SignUpVM sut;
    setUp(() => sut = _SignUpVM());
    tearDown(() => sut.dispose());

    test('isValid is false before validateAll is called', () {
      expect(sut.isValid, isFalse);
    });

    test('empty fields produce errors', () {
      sut.validateAll();
      expect(sut.errorFor('email'), equals('Email is required'));
      expect(sut.errorFor('password'), equals('Min 6 characters'));
    });

    test('bad email format produces error', () {
      sut.email = 'notanemail';
      sut.password = 'secret123';
      sut.validateAll();
      expect(sut.errorFor('email'), equals('Enter a valid email'));
    });

    test('isValid is true when all fields pass', () {
      sut.email = 'a@b.com';
      sut.password = 'secret123';
      expect(sut.validateAll(), isTrue);
      expect(sut.isValid, isTrue);
    });

    test('clearFieldErrors resets all errors', () {
      sut.validateAll();
      sut.clearFieldErrors();
      expect(sut.fieldErrors.isEmpty, isTrue);
    });

    test('setFieldError notifies listeners', () {
      int count = 0;
      sut.addListener(() => count++);
      sut.setFieldError('email', 'oops');
      expect(count, equals(1));
    });
  });
}
