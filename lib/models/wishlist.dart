import 'package:hive/hive.dart';
import 'task.dart';

part 'wishlist.g.dart';

@HiveType(typeId: 0)
class WishList extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  DateTime? deadline; // オプショナルに変更（後方互換性のため保持）
  @HiveField(3)
  List<Task> tasks;
  @HiveField(4)
  int? year; // 年度（nullは旧データ）

  WishList({
    required this.id,
    required this.title,
    this.deadline, // オプショナルに
    this.tasks = const [],
    this.year,
  });

  // 完了率を取得する。
  double get completionRate {
    if (tasks.isEmpty) return 0;
    final completed = tasks.where((task) => task.isCompleted).length;
    return completed / tasks.length;
  }

  WishList copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    List<Task>? tasks,
    int? year,
  }) {
    return WishList(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      tasks: tasks ?? this.tasks,
      year: year ?? this.year,
    );
  }
}
