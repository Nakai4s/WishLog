import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/wishlist.dart';
import 'package:hive/hive.dart';

// デフォルトウィッシュリストのID（固定）
const _defaultWishListId = 'default-wishlist';

final wishListProvider =
    NotifierProvider<WishListNotifier, List<WishList>>(WishListNotifier.new);

// デフォルトウィッシュリストを取得するプロバイダー
final defaultWishListProvider = Provider<WishList?>((ref) {
  final wishLists = ref.watch(wishListProvider);
  if (wishLists.isEmpty) return null;
  // デフォルトウィッシュリストを探す、なければ最初のものを返す
  return wishLists.firstWhere(
    (w) => w.id == _defaultWishListId,
    orElse: () => wishLists.first,
  );
});

class WishListNotifier extends Notifier<List<WishList>> {
  static const _uuid = Uuid();
  late Box<WishList> _box;

  @override
  List<WishList> build() {
    _box = Hive.box<WishList>('wishlists');
    _ensureDefaultWishListExists();
    _migrateMultipleWishLists();
    return _box.values.toList();
  }

  // デフォルトウィッシュリストが存在しない場合は作成
  Future<void> _ensureDefaultWishListExists() async {
    if (_box.isEmpty) {
      final defaultWish = WishList(
        id: _defaultWishListId,
        title: 'ウィッシュログ',
        tasks: [],
      );
      await _box.put(_defaultWishListId, defaultWish);
    }
  }

  // 複数ウィッシュリストがある場合、タスクを統合してマイグレーション
  Future<void> _migrateMultipleWishLists() async {
    if (_box.length <= 1) return;

    // デフォルトウィッシュリストを取得または作成
    WishList? defaultWish = _box.get(_defaultWishListId);
    if (defaultWish == null) {
      // デフォルトが無い場合は最初のものをデフォルトとして使用
      final first = _box.values.first;
      defaultWish = WishList(
        id: _defaultWishListId,
        title: 'ウィッシュログ',
        tasks: List<Task>.from(first.tasks),
      );
      await _box.put(_defaultWishListId, defaultWish);
    }

    // 他のウィッシュリストからタスクを統合
    final allTasks = <Task>[];
    allTasks.addAll(defaultWish.tasks);

    final keysToDelete = <String>[];
    for (final wish in _box.values) {
      if (wish.id != _defaultWishListId) {
        allTasks.addAll(wish.tasks);
        keysToDelete.add(wish.id);
      }
    }

    // タスクを統合して保存
    defaultWish.tasks = allTasks;
    await defaultWish.save();

    // 他のウィッシュリストを削除
    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }

  // デフォルトウィッシュリストを取得
  WishList? get defaultWishList {
    return _box.get(_defaultWishListId) ?? _box.values.firstOrNull;
  }

  // 状態を更新（新しいオブジェクトを作成してRiverpodに変更を検知させる）
  void _updateState() {
    state = _box.values
        .map((w) => w.copyWith(tasks: List<Task>.from(w.tasks)))
        .toList();
  }

  // タスクを追加
  Future<void> addTask(String taskTitle) async {
    final wish = defaultWishList;
    if (wish == null) return;
    final task = Task(id: _uuid.v4(), title: taskTitle);
    wish.tasks = [...wish.tasks, task];
    await wish.save();
    _updateState();
  }

  // タスクの完了状態をトグル
  Future<void> toggleTaskComplete(String taskId) async {
    final wish = defaultWishList;
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
  Future<void> removeTask(String taskId) async {
    final wish = defaultWishList;
    if (wish == null) return;
    wish.tasks = wish.tasks.where((t) => t.id != taskId).toList();
    await wish.save();
    _updateState();
  }
}
