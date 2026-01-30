import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final bool isCompleted;
  @HiveField(3)
  final int? year;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.year,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? year,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      year: year ?? this.year,
    );
  }
}
