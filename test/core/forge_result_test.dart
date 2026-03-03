import 'package:flutter_test/flutter_test.dart';
import 'package:forge_mvvm/forge_mvvm.dart';

void main() {
  group('ForgeResult', () {
    test('ForgeSuccess carries data and reports isSuccess=true', () {
      final result = ForgeResult<int>.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals(42));
      expect(result.exceptionOrNull, isNull);
    });

    test('ForgeFailure carries exception and reports isFailure=true', () {
      const exception = ForgeNetworkException('timeout');
      final result = ForgeResult<int>.failure(exception);
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.exceptionOrNull, equals(exception));
    });

    test('when() calls success branch on ForgeSuccess', () {
      final result = ForgeResult<String>.success('hello');
      final output = result.when(
        success: (d) => 'got: $d',
        failure: (_) => 'failed',
      );
      expect(output, equals('got: hello'));
    });

    test('when() calls failure branch on ForgeFailure', () {
      const ex = ForgeNetworkException('oops');
      final result = ForgeResult<String>.failure(ex);
      final output = result.when(
        success: (_) => 'ok',
        failure: (e) => 'error',
      );
      expect(output, equals('error'));
    });
  });
}
