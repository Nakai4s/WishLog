import 'task.dart';

class WishList {
  final String id;
  final String title;
  final DateTime deadline;
  final List<Task> tasks;

  WishList({
    required this.id,
    required this.title,
    required this.deadline,
    this.tasks = const [],
  });

  // 完了率を取得する。
  double get completionRate {
    if (tasks.isEmpty) return 0;
    final completed = tasks.where((task) => task.isCompleted).length;
    return completed / tasks.length;
  }

  // 残り日数を取得する。
  int get remainingDays {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }

  WishList copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    List<Task>? tasks,
  }) {
    return WishList(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      tasks: tasks ?? this.tasks,
    );
  }
}
