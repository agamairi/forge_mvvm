import 'package:flutter_test/flutter_test.dart';
import 'package:forge_mvvm/forge_mvvm.dart';

void main() {
  group('ForgeCommand', () {
    test('isRunning is false initially', () {
      final cmd = ForgeCommand<void>((_) async {});
      expect(cmd.isRunning, isFalse);
      expect(cmd.hasError, isFalse);
    });

    test('isRunning is true during execution', () async {
      bool wasRunning = false;
      final cmd = ForgeCommand<void>((_) async {
        await Future.delayed(const Duration(milliseconds: 20));
      });
      final future = cmd.execute();
      wasRunning = cmd.isRunning;
      await future;
      expect(wasRunning, isTrue);
      expect(cmd.isRunning, isFalse);
    });

    test('does not re-enter when already running', () async {
      int callCount = 0;
      final cmd = ForgeCommand<void>((_) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 30));
      });
      final f1 = cmd.execute();
      final f2 = cmd.execute();
      await Future.wait([f1, f2]);
      expect(callCount, equals(1));
    });

    test('captures exception in lastException', () async {
      final cmd = ForgeCommand<void>((_) async {
        throw const ForgeNetworkException('failed');
      });
      await cmd.execute();
      expect(cmd.hasError, isTrue);
      expect(cmd.lastException, isA<ForgeNetworkException>());
    });

    test('notifies listeners on start and finish', () async {
      int count = 0;
      final cmd = ForgeCommand<void>((_) async {});
      cmd.addListener(() => count++);
      await cmd.execute();
      expect(count, equals(2));
    });
  });
}
