import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/wishlist.dart';

final wishListProvider = StateNotifierProvider<WishListNotifier, List<WishList>>(
  (ref) => WishListNotifier(),
);

class WishListNotifier extends StateNotifier<List<WishList>> {
  WishListNotifier() : super([]);

  final _uuid = Uuid();

  void addWishList(String title, DateTime deadLine) {
    final newWishList = WishList(
      id: _uuid.v4(),
      title: title, 
      deadline: deadLine,
      tasks: [],
    );
    state = [...state, newWishList];
  }

  void deleteWishList(String id) {
    state = state.where((wish) => wish.id != id).toList();
  }

  void addTaskToWishList(String wishListId, String taskTitle) {
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
  }

  void toggleTaskComplete(String wishListId, String taskId) {
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
  }

}