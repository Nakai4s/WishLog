import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wishlog/models/task.dart';
import 'package:wishlog/providers/wishlist_provider.dart';

void main() {
  group('StatusFilterNotifier', () {
    test('初期値は StatusFilter.all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(statusFilterProvider), StatusFilter.all);
    });

    test('setFilter で completed に変更できる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(statusFilterProvider.notifier).setFilter(StatusFilter.completed);
      expect(container.read(statusFilterProvider), StatusFilter.completed);
    });

    test('setFilter で incomplete に変更できる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(statusFilterProvider.notifier).setFilter(StatusFilter.incomplete);
      expect(container.read(statusFilterProvider), StatusFilter.incomplete);
    });
  });

  group('filteredTasksProvider', () {
    final testTasks = [
      Task(id: '1', title: 'タスク1', isCompleted: false),
      Task(id: '2', title: 'タスク2', isCompleted: true),
      Task(id: '3', title: 'タスク3', isCompleted: false),
      Task(id: '4', title: 'タスク4', isCompleted: true),
    ];

    ProviderContainer createContainer({List<Task> tasks = const []}) {
      return ProviderContainer(
        overrides: [
          yearTasksProvider.overrideWithValue(tasks),
        ],
      );
    }

    test('StatusFilter.all は全タスクを返す', () {
      final container = createContainer(tasks: testTasks);
      addTearDown(container.dispose);

      final filtered = container.read(filteredTasksProvider);
      expect(filtered.length, 4);
    });

    test('StatusFilter.incomplete は未完了タスクのみ返す', () {
      final container = createContainer(tasks: testTasks);
      addTearDown(container.dispose);

      container.read(statusFilterProvider.notifier).setFilter(StatusFilter.incomplete);
      final filtered = container.read(filteredTasksProvider);
      expect(filtered.length, 2);
      expect(filtered.every((t) => !t.isCompleted), true);
    });

    test('StatusFilter.completed は完了タスクのみ返す', () {
      final container = createContainer(tasks: testTasks);
      addTearDown(container.dispose);

      container.read(statusFilterProvider.notifier).setFilter(StatusFilter.completed);
      final filtered = container.read(filteredTasksProvider);
      expect(filtered.length, 2);
      expect(filtered.every((t) => t.isCompleted), true);
    });

    test('タスクが空の場合は空リストを返す', () {
      final container = createContainer(tasks: []);
      addTearDown(container.dispose);

      final filtered = container.read(filteredTasksProvider);
      expect(filtered, isEmpty);
    });
  });

  group('filteredCompletionRateProvider', () {
    ProviderContainer createContainer({List<Task> tasks = const []}) {
      return ProviderContainer(
        overrides: [
          yearTasksProvider.overrideWithValue(tasks),
        ],
      );
    }

    test('タスクが空の場合は 0.0 を返す', () {
      final container = createContainer(tasks: []);
      addTearDown(container.dispose);

      expect(container.read(filteredCompletionRateProvider), 0.0);
    });

    test('全タスク完了の場合は 1.0 を返す', () {
      final container = createContainer(tasks: [
        Task(id: '1', title: 'タスク1', isCompleted: true),
        Task(id: '2', title: 'タスク2', isCompleted: true),
      ]);
      addTearDown(container.dispose);

      expect(container.read(filteredCompletionRateProvider), 1.0);
    });

    test('半分完了の場合は 0.5 を返す', () {
      final container = createContainer(tasks: [
        Task(id: '1', title: 'タスク1', isCompleted: true),
        Task(id: '2', title: 'タスク2', isCompleted: false),
      ]);
      addTearDown(container.dispose);

      expect(container.read(filteredCompletionRateProvider), 0.5);
    });

    test('1/3 完了の場合は正しい割合を返す', () {
      final container = createContainer(tasks: [
        Task(id: '1', title: 'タスク1', isCompleted: true),
        Task(id: '2', title: 'タスク2', isCompleted: false),
        Task(id: '3', title: 'タスク3', isCompleted: false),
      ]);
      addTearDown(container.dispose);

      expect(
        container.read(filteredCompletionRateProvider),
        closeTo(1 / 3, 0.001),
      );
    });
  });
}
