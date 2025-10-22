import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/wishlist.dart';
import 'package:hive/hive.dart';

final wishListProvider = StateNotifierProvider<WishListNotifier, List<WishList>>(
  (ref) => WishListNotifier()..loadFromStorage(),
);

class WishListNotifier extends StateNotifier<List<WishList>> {
  WishListNotifier() : super([]);

  final _uuid = Uuid();
  late final Box<WishList> _box;

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
    final newWishList = WishList(
      id: _uuid.v4(),
      title: title,
      deadline: deadline,
      tasks: [],
    );
    state = [...state, newWishList];
    await saveToStorage();
  }

  // ウィッシュリストを削除
  Future<void> deleteWishList(String id) async {
    state = state.where((wish) => wish.id != id).toList();
    await saveToStorage();
  }

  // タスクを追加
  Future<void> addTaskToWishList(String wishListId, String taskTitle) async {
    state = state.map((wish) {
      if (wish.id == wishListId) {
        final newTask = Task(
          id: _uuid.v4(),
          title: taskTitle,
        );
        return wish.copyWith(tasks: [...wish.tasks, newTask]);
      }
      return wish;
    }).toList();
    await saveToStorage();
  }

  // タスクの完了状態を切り替え
  Future<void> toggleTaskComplete(String wishListId, String taskId) async {
    state = state.map((wish) {
      if (wish.id == wishListId) {
        final updatedTasks = wish.tasks.map((task) {
          if (task.id == taskId) {
            return task.copyWith(isCompleted: !task.isCompleted);
          }
          return task;
        }).toList();
        return wish.copyWith(tasks: updatedTasks);
      }
      return wish;
    }).toList();
    await saveToStorage();
  }

  void updateWishList(WishList updated) {
    state = state.map((wish) {
      if (wish.id == updated.id) return updated;
      return wish;
    }).toList();
    saveToStorage();
  }
}