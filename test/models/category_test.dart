import 'package:flutter_test/flutter_test.dart';
import 'package:wishlog/models/category.dart';

void main() {
  group('TaskCategory displayName', () {
    test('work は 仕事 を返す', () {
      expect(TaskCategory.work.displayName, '仕事');
    });

    test('health は 健康 を返す', () {
      expect(TaskCategory.health.displayName, '健康');
    });

    test('hobby は 趣味 を返す', () {
      expect(TaskCategory.hobby.displayName, '趣味');
    });

    test('relationship は 人間関係 を返す', () {
      expect(TaskCategory.relationship.displayName, '人間関係');
    });

    test('money は お金 を返す', () {
      expect(TaskCategory.money.displayName, 'お金');
    });

    test('learning は 学び を返す', () {
      expect(TaskCategory.learning.displayName, '学び');
    });

    test('other は その他 を返す', () {
      expect(TaskCategory.other.displayName, 'その他');
    });

    test('全カテゴリの displayName が空文字でない', () {
      for (final category in TaskCategory.values) {
        expect(category.displayName, isNotEmpty);
      }
    });
  });
}
