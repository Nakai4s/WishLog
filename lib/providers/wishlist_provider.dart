import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/wishlist.dart';
import 'package:hive/hive.dart';
import 'year_provider.dart';

// ステータスフィルター
enum StatusFilter { all, incomplete, completed }

final statusFilterProvider =
    NotifierProvider<StatusFilterNotifier, StatusFilter>(
        StatusFilterNotifier.new);

class StatusFilterNotifier extends Notifier<StatusFilter> {
  @override
  StatusFilter build() => StatusFilter.all;

  void setFilter(StatusFilter filter) {
    state = filter;
  }
}

final wishListProvider =
    NotifierProvider<WishListNotifier, List<WishList>>(WishListNotifier.new);

// 選択中の年度のウィッシュリストを取得するプロバイダー
final currentYearWishListProvider = Provider<WishList?>((ref) {
  final wishLists = ref.watch(wishListProvider);
  final selectedYear = ref.watch(selectedYearProvider);

  if (wishLists.isEmpty || selectedYear == null) return null;

  return wishLists.cast<WishList?>().firstWhere(
        (w) => w?.year == selectedYear,
        orElse: () => null,
      );
});

// 年度の全タスク（ステータスフィルター前）
final yearTasksProvider = Provider<List<Task>>((ref) {
  final wish = ref.watch(currentYearWishListProvider);
  if (wish == null) return [];
  return wish.tasks;
});

// ステータスフィルター適用後のタスク一覧
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(yearTasksProvider);
  final statusFilter = ref.watch(statusFilterProvider);

  switch (statusFilter) {
    case StatusFilter.all:
      return tasks;
    case StatusFilter.incomplete:
      return tasks.where((t) => !t.isCompleted).toList();
    case StatusFilter.completed:
      return tasks.where((t) => t.isCompleted).toList();
  }
});

// 達成率（年度全体ベース）
final filteredCompletionRateProvider = Provider<double>((ref) {
  final tasks = ref.watch(yearTasksProvider);
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
    var migrated = false;

    for (final wish in _box.values.toList()) {
      if (wish.year == null) {
        final tasksByYear = <int, List<Task>>{};

        for (final task in wish.tasks) {
          final taskYear = task.year ?? currentYear;
          tasksByYear.putIfAbsent(taskYear, () => []).add(task);
        }

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

        await _box.delete(wish.id);
        migrated = true;
      }
    }

    if (migrated) {
      _updateState();
    }
  }

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

  void _updateState() {
    state = _box.values
        .map((w) => w.copyWith(tasks: List<Task>.from(w.tasks)))
        .toList();
  }

  Future<void> addTask(String taskTitle, {required int year}) async {
    final wish = await getOrCreateYearWishList(year);
    final task = Task(
      id: _uuid.v4(),
      title: taskTitle,
      year: year,
    );
    wish.tasks = [...wish.tasks, task];
    await wish.save();
    _updateState();
  }

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

  Future<void> removeTask(String taskId, int year) async {
    final wishId = 'wishlist-$year';
    final wish = _box.get(wishId);
    if (wish == null) return;

    wish.tasks = wish.tasks.where((t) => t.id != taskId).toList();
    await wish.save();
    _updateState();
  }
}
