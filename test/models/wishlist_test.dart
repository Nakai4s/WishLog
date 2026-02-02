import 'package:flutter_test/flutter_test.dart';
import 'package:wishlog/models/task.dart';
import 'package:wishlog/models/wishlist.dart';

void main() {
  group('WishList', () {
    group('completionRate', () {
      test('タスクが空の場合は 0 を返す', () {
        final wishList = WishList(id: '1', title: 'テスト', tasks: []);
        expect(wishList.completionRate, 0);
      });

      test('全タスクが完了の場合は 1.0 を返す', () {
        final wishList = WishList(
          id: '1',
          title: 'テスト',
          tasks: [
            Task(id: '1', title: 'タスク1', isCompleted: true),
            Task(id: '2', title: 'タスク2', isCompleted: true),
          ],
        );
        expect(wishList.completionRate, 1.0);
      });

      test('部分完了の場合は正しい割合を返す', () {
        final wishList = WishList(
          id: '1',
          title: 'テスト',
          tasks: [
            Task(id: '1', title: 'タスク1', isCompleted: true),
            Task(id: '2', title: 'タスク2', isCompleted: false),
            Task(id: '3', title: 'タスク3', isCompleted: true),
            Task(id: '4', title: 'タスク4', isCompleted: false),
          ],
        );
        expect(wishList.completionRate, 0.5);
      });

      test('全タスクが未完了の場合は 0 を返す', () {
        final wishList = WishList(
          id: '1',
          title: 'テスト',
          tasks: [
            Task(id: '1', title: 'タスク1', isCompleted: false),
            Task(id: '2', title: 'タスク2', isCompleted: false),
          ],
        );
        expect(wishList.completionRate, 0);
      });
    });

    group('copyWith', () {
      final original = WishList(
        id: '1',
        title: '元のリスト',
        year: 2026,
        tasks: [Task(id: 't1', title: 'タスク1')],
      );

      test('フィールドを置換できる', () {
        final copied = original.copyWith(title: '新しいリスト', year: 2027);
        expect(copied.title, '新しいリスト');
        expect(copied.year, 2027);
      });

      test('指定しないフィールドは元の値を保持する', () {
        final copied = original.copyWith(title: '新しいリスト');
        expect(copied.id, '1');
        expect(copied.year, 2026);
        expect(copied.tasks.length, 1);
      });

      test('tasks を置換できる', () {
        final newTasks = [
          Task(id: 't2', title: 'タスク2'),
          Task(id: 't3', title: 'タスク3'),
        ];
        final copied = original.copyWith(tasks: newTasks);
        expect(copied.tasks.length, 2);
        expect(copied.tasks[0].id, 't2');
      });
    });
  });
}
