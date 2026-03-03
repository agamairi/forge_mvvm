import 'package:flutter_test/flutter_test.dart';
import 'package:forge_mvvm/forge_mvvm.dart';

void main() {
  group('ForgeException', () {
    test('toString includes message when no code', () {
      const e = ForgeException('something went wrong');
      expect(e.toString(), contains('something went wrong'));
    });

    test('toString includes code when provided', () {
      const e = ForgeException('not found', code: '404');
      expect(e.toString(), contains('404'));
      expect(e.toString(), contains('not found'));
    });

    test('ForgeNetworkException is a ForgeException', () {
      const e = ForgeNetworkException('timeout');
      expect(e, isA<ForgeException>());
    });

    test('ForgeValidationException carries message', () {
      const e = ForgeValidationException('email is required');
      expect(e.message, equals('email is required'));
    });
  });
}
