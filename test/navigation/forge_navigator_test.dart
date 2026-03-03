import 'package:flutter_test/flutter_test.dart';
import 'package:forge_mvvm/forge_mvvm.dart';

void main() {
  group('NavigationEvent', () {
    test('PushRoute holds location', () {
      const e = PushRoute('/home');
      expect(e.location, equals('/home'));
      expect(e, isA<NavigationEvent>());
    });

    test('ReplaceRoute holds location', () {
      const e = ReplaceRoute('/login');
      expect(e.location, equals('/login'));
      expect(e, isA<NavigationEvent>());
    });

    test('PopRoute is a NavigationEvent', () {
      const e = PopRoute();
      expect(e, isA<NavigationEvent>());
    });
  });
}
