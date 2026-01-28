import 'package:flutter_riverpod/flutter_riverpod.dart';

// 選択可能な年度リスト（現在年から前後5年）
final availableYearsProvider = Provider<List<int>>((ref) {
  final currentYear = DateTime.now().year;
  return List.generate(11, (index) => currentYear - 5 + index);
});

// 選択中の年度（nullは「すべて」を意味する）
final selectedYearProvider =
    NotifierProvider<SelectedYearNotifier, int?>(SelectedYearNotifier.new);

class SelectedYearNotifier extends Notifier<int?> {
  @override
  int? build() {
    return DateTime.now().year;
  }

  void setYear(int? year) {
    state = year;
  }
}
