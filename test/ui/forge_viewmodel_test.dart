import 'package:flutter_test/flutter_test.dart';
import 'package:forge_mvvm/forge_mvvm.dart';

class _TestViewModel extends ForgeViewModel {
  bool initCalled = false;
  bool disposeCalled = false;
  int counter = 0;

  @override
  void onInit() => initCalled = true;

  @override
  void onDispose() => disposeCalled = true;

  void increment() {
    counter++;
    notifyListeners();
  }

  void publicClearError() => clearError();

  Future<void> slowAction() async {
    await runBusyAction(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      counter++;
    });
  }

  Future<void> failingAction() async {
    await runBusyAction(() async {
      throw const ForgeNetworkException('Network error');
    });
  }
}

void main() {
  group('ForgeViewModel', () {
    late _TestViewModel sut;

    setUp(() => sut = _TestViewModel());
    tearDown(() {
      if (!sut.isDisposed) sut.dispose();
    });

    test('starts with isLoading=false and no error', () {
      expect(sut.isLoading, isFalse);
      expect(sut.errorMessage, isNull);
    });

    test('onInit is called by test harness', () {
      sut.onInit();
      expect(sut.initCalled, isTrue);
    });

    test('notifyListeners triggers listeners', () {
      int count = 0;
      sut.addListener(() => count++);
      sut.increment();
      expect(count, equals(1));
      expect(sut.counter, equals(1));
    });

    test('runBusyAction sets and clears isLoading', () async {
      final future = sut.slowAction();
      expect(sut.isLoading, isTrue);
      await future;
      expect(sut.isLoading, isFalse);
      expect(sut.counter, equals(1));
    });

    test('runBusyAction captures exception as errorMessage', () async {
      await sut.failingAction();
      expect(sut.isLoading, isFalse);
      expect(sut.errorMessage, isNotNull);
      expect(sut.errorMessage, contains('Network error'));
    });

    test('clearError removes errorMessage', () async {
      await sut.failingAction();
      sut.publicClearError();
      expect(sut.errorMessage, isNull);
    });

    test('onDispose is called on dispose()', () {
      sut.dispose();
      expect(sut.disposeCalled, isTrue);
    });

    test('notifyListeners is safe after dispose', () {
      sut.dispose();
      expect(() => sut.notifyListeners(), returnsNormally);
    });
  });
}
