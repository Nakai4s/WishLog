import 'package:flutter_test/flutter_test.dart';
import 'package:wishlog/models/task.dart';

void main() {
  group('Task', () {
    group('コンストラクタ', () {
      test('isCompleted のデフォルト値は false', () {
        final task = Task(id: '1', title: 'テスト');
        expect(task.isCompleted, false);
      });

      test('year のデフォルト値は null', () {
        final task = Task(id: '1', title: 'テスト');
        expect(task.year, isNull);
      });

      test('全フィールドを指定して生成できる', () {
        final task = Task(
          id: '1',
          title: 'テスト',
          isCompleted: true,
          year: 2026,
        );
        expect(task.id, '1');
        expect(task.title, 'テスト');
        expect(task.isCompleted, true);
        expect(task.year, 2026);
      });
    });

    group('copyWith', () {
      final original = Task(
        id: '1',
        title: '元のタスク',
        isCompleted: false,
        year: 2026,
      );

      test('フィールドを置換できる', () {
        final copied = original.copyWith(
          title: '新しいタスク',
          isCompleted: true,
        );
        expect(copied.title, '新しいタスク');
        expect(copied.isCompleted, true);
      });

      test('指定しないフィールドは元の値を保持する', () {
        final copied = original.copyWith(title: '新しいタスク');
        expect(copied.id, '1');
        expect(copied.isCompleted, false);
        expect(copied.year, 2026);
      });

      test('全フィールドを置換できる', () {
        final copied = original.copyWith(
          id: '2',
          title: '別のタスク',
          isCompleted: true,
          year: 2027,
        );
        expect(copied.id, '2');
        expect(copied.title, '別のタスク');
        expect(copied.isCompleted, true);
        expect(copied.year, 2027);
      });
    });
  });
}
