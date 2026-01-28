import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';

// 選択中のカテゴリフィルター（nullは「すべて」を意味する）
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, TaskCategory?>(
        SelectedCategoryNotifier.new);

class SelectedCategoryNotifier extends Notifier<TaskCategory?> {
  @override
  TaskCategory? build() {
    return null;
  }

  void setCategory(TaskCategory? category) {
    state = category;
  }
}
