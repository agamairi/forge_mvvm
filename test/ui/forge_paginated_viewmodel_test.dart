import 'package:flutter_test/flutter_test.dart';
import 'package:forge_mvvm/forge_mvvm.dart';

class _NumbersVM extends ForgePaginatedViewModel<int> {
  @override
  Future<List<int>> loadPage(int page) async {
    if (page > 2) return <int>[];
    return List<int>.generate(3, (i) => (page - 1) * 3 + i);
  }
}

class _ErrorVM extends ForgePaginatedViewModel<int> {
  @override
  Future<List<int>> loadPage(int page) async {
    throw const ForgeNetworkException('no connection');
  }
}

void main() {
  group('ForgePaginatedViewModel', () {
    test('loads first page correctly', () async {
      final vm = _NumbersVM();
      await vm.loadNextPage();
      expect(vm.items, equals([0, 1, 2]));
      expect(vm.currentPage, equals(1));
      expect(vm.hasMore, isTrue);
    });

    test('appends second page without duplicates', () async {
      final vm = _NumbersVM();
      await vm.loadNextPage();
      await vm.loadNextPage();
      expect(vm.items, equals([0, 1, 2, 3, 4, 5]));
      expect(vm.currentPage, equals(2));
    });

    test('sets hasMore=false on empty page', () async {
      final vm = _NumbersVM();
      await vm.loadNextPage();
      await vm.loadNextPage();
      await vm.loadNextPage();
      expect(vm.hasMore, isFalse);
    });

    test('loadNextPage is no-op when hasMore=false', () async {
      final vm = _NumbersVM();
      await vm.loadNextPage();
      await vm.loadNextPage();
      await vm.loadNextPage();
      final page = vm.currentPage;
      await vm.loadNextPage();
      expect(vm.currentPage, equals(page));
    });

    test('refresh resets and reloads from page 1', () async {
      final vm = _NumbersVM();
      await vm.loadNextPage();
      await vm.loadNextPage();
      await vm.refresh();
      expect(vm.items.length, equals(3));
      expect(vm.currentPage, equals(1));
    });

    test('sets errorMessage on exception', () async {
      final vm = _ErrorVM();
      await vm.loadNextPage();
      expect(vm.errorMessage, isNotNull);
      expect(vm.isLoading, isFalse);
      expect(vm.isLoadingMore, isFalse);
    });
  });
}
