import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
enum TaskCategory {
  @HiveField(0)
  work, // 仕事

  @HiveField(1)
  health, // 健康

  @HiveField(2)
  hobby, // 趣味

  @HiveField(3)
  relationship, // 人間関係

  @HiveField(4)
  money, // お金

  @HiveField(5)
  learning, // 学び

  @HiveField(6)
  other, // その他
}

extension TaskCategoryExtension on TaskCategory {
  String get displayName {
    switch (this) {
      case TaskCategory.work:
        return '仕事';
      case TaskCategory.health:
        return '健康';
      case TaskCategory.hobby:
        return '趣味';
      case TaskCategory.relationship:
        return '人間関係';
      case TaskCategory.money:
        return 'お金';
      case TaskCategory.learning:
        return '学び';
      case TaskCategory.other:
        return 'その他';
    }
  }
}
