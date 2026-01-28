import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/wishlist.dart';
import 'package:hive/hive.dart';
import 'year_provider.dart';
import 'category_provider.dart';

final wishListProvider =
    NotifierProvider<WishListNotifier, List<WishList>>(WishListNotifier.new);

// 選択中の年度のウィッシュリストを取得するプロバイダー
final currentYearWishListProvider = Provider<WishList?>((ref) {
  final wishLists = ref.watch(wishListProvider);
  final selectedYear = ref.watch(selectedYearProvider);

  if (wishLists.isEmpty || selectedYear == null) return null;

  // 選択中の年度のウィッシュリストを探す
  return wishLists.cast<WishList?>().firstWhere(
        (w) => w?.year == selectedYear,
        orElse: () => null,
      );
});

// カテゴリでフィルタリングされたタスク一覧
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final wish = ref.watch(currentYearWishListProvider);
  if (wish == null) return [];

  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == null) {
    return wish.tasks;
  }

  return wish.tasks.where((task) => task.category == selectedCategory).toList();
});

// フィルター後の達成率
final filteredCompletionRateProvider = Provider<double>((ref) {
  final tasks = ref.watch(filteredTasksProvider);
  if (tasks.isEmpty) return 0.0;
  final completedCount = tasks.where((t) => t.isCompleted).length;
  return completedCount / tasks.length;
});

class WishListNotifier extends Notifier<List<WishList>> {
  static const _uuid = Uuid();
  late Box<WishList> _box;

  @override
  List<WishList> build() {
    _box = Hive.box<WishList>('wishlists');
    _migrateOldData();
    return _box.values.toList();
  }

  // 旧データのマイグレーション（yearがnullのウィッシュリストを処理）
  Future<void> _migrateOldData() async {
    final currentYear = DateTime.now().year;

    for (final wish in _box.values.toList()) {
      if (wish.year == null) {
        // 旧データの場合、タスクを年度ごとに振り分け
        final tasksByYear = <int, List<Task>>{};

        for (final task in wish.tasks) {
          final taskYear = task.year ?? currentYear;
          tasksByYear.putIfAbsent(taskYear, () => []).add(task);
        }

        // 各年度のウィッシュリストを作成
        for (final entry in tasksByYear.entries) {
          final yearWishId = 'wishlist-${entry.key}';
          var yearWish = _box.get(yearWishId);

          if (yearWish == null) {
            yearWish = WishList(
              id: yearWishId,
              title: '${entry.key}年の目標',
              year: entry.key,
              tasks: entry.value,
            );
            await _box.put(yearWishId, yearWish);
          } else {
            yearWish.tasks = [...yearWish.tasks, ...entry.value];
            await yearWish.save();
          }
        }

        // 旧ウィッシュリストを削除
        await _box.delete(wish.id);
      }
    }
  }

  // 指定年度のウィッシュリストを取得（なければ作成）
  Future<WishList> getOrCreateYearWishList(int year) async {
    final wishId = 'wishlist-$year';
    var wish = _box.get(wishId);

    if (wish == null) {
      wish = WishList(
        id: wishId,
        title: '$year年の目標',
        year: year,
        tasks: [],
      );
      await _box.put(wishId, wish);
      _updateState();
    }

    return wish;
  }

  // 状態を更新
  void _updateState() {
    state = _box.values
        .map((w) => w.copyWith(tasks: List<Task>.from(w.tasks)))
        .toList();
  }

  // タスクを追加
  Future<void> addTask(
    String taskTitle, {
    required int year,
    TaskCategory? category,
  }) async {
    final wish = await getOrCreateYearWishList(year);
    final task = Task(
      id: _uuid.v4(),
      title: taskTitle,
      year: year,
      category: category,
    );
    wish.tasks = [...wish.tasks, task];
    await wish.save();
    _updateState();
  }

  // タスクの完了状態をトグル
  Future<void> toggleTaskComplete(String taskId, int year) async {
    final wishId = 'wishlist-$year';
    final wish = _box.get(wishId);
    if (wish == null) return;

    final updated = wish.tasks.map((t) {
      if (t.id == taskId) return t.copyWith(isCompleted: !t.isCompleted);
      return t;
    }).toList();
    wish.tasks = updated;
    await wish.save();
    _updateState();
  }

  // タスクを削除
  Future<void> removeTask(String taskId, int year) async {
    final wishId = 'wishlist-$year';
    final wish = _box.get(wishId);
    if (wish == null) return;

    wish.tasks = wish.tasks.where((t) => t.id != taskId).toList();
    await wish.save();
    _updateState();
  }
}
