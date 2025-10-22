import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/wishlist.dart';
import 'package:hive/hive.dart';

final wishListProvider =
    NotifierProvider<WishListNotifier, List<WishList>>(WishListNotifier.new);

class WishListNotifier extends Notifier<List<WishList>> {
  final _uuid = Uuid();
  late Box<WishList> _box;

  @override
  List<WishList> build() {
    _box = Hive.box<WishList>('wishlists');
    return _box.values.toList();
  }

  // 初期化：Hive Boxを開いてデータ読み込み
  Future<void> loadFromStorage() async {
    _box = Hive.box<WishList>('wishlists');
    state = _box.values.toList();
  }

  // 保存：全件保存（上書き）
  Future<void> saveToStorage() async {
    await _box.clear();
    for (final wish in state) {
      await _box.put(wish.id, wish);
    }
  }

  // ウィッシュリストを追加
  Future<void> addWishList(String title, DateTime deadline) async {
    final id = _uuid.v4();
    final wish = WishList(id: id, title: title, deadline: deadline, tasks: []);
    await _box.put(id, wish); // id をキーとして保存
    state = _box.values.toList();
  }

  Future<void> deleteWishListById(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

  Future<void> updateWishListById(String id, {String? title, DateTime? deadline}) async {
    final wish = _box.get(id);
    if (wish == null) return;
    if (title != null) wish.title = title;
    if (deadline != null) wish.deadline = deadline;
    await wish.save(); // HiveObject の save()
    state = _box.values.toList();
  }

  Future<void> addTaskToWishList(String wishId, String taskTitle) async {
    final wish = _box.get(wishId);
    if (wish == null) return;
    final task = Task(id: _uuid.v4(), title: taskTitle);
    wish.tasks = [...wish.tasks, task];
    await wish.save();
    state = _box.values.toList();
  }

  Future<void> toggleTaskComplete(String wishId, String taskId) async {
    final wish = _box.get(wishId);
    if (wish == null) return;
    final updated = wish.tasks.map((t) {
      if (t.id == taskId) return t.copyWith(isCompleted: !t.isCompleted);
      return t;
    }).toList();
    wish.tasks = updated;
    await wish.save();
    state = _box.values.toList();
  }

  Future<void> removeTask(String wishId, String taskId) async {
    final wish = _box.get(wishId);
    if (wish == null) return;
    wish.tasks = wish.tasks.where((t) => t.id != taskId).toList();
    await wish.save();
    state = _box.values.toList();
  }
}