import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wishlog/providers/year_provider.dart';

void main() {
  group('availableYearsProvider', () {
    test('現在年を中心に前後5年の11要素リストを返す', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final years = container.read(availableYearsProvider);
      final currentYear = DateTime.now().year;

      expect(years.length, 11);
      expect(years.first, currentYear - 5);
      expect(years.last, currentYear + 5);
      expect(years.contains(currentYear), true);
    });
  });

  group('SelectedYearNotifier', () {
    test('初期値は現在年', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final year = container.read(selectedYearProvider);
      expect(year, DateTime.now().year);
    });

    test('setYear で年を変更できる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedYearProvider.notifier).setYear(2025);
      expect(container.read(selectedYearProvider), 2025);
    });

    test('setYear(null) で null に設定できる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedYearProvider.notifier).setYear(null);
      expect(container.read(selectedYearProvider), isNull);
    });
  });
}
