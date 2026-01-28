// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/wishlist_provider.dart';
import '../providers/year_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wish = ref.watch(defaultWishListProvider);
    final notifier = ref.read(wishListProvider.notifier);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final completionRate = ref.watch(filteredCompletionRateProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final availableYears = ref.watch(availableYearsProvider);

    if (wish == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ウィッシュログ'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ウィッシュログ'),
        actions: [
          // 年度選択ドロップダウン
          DropdownButton<int?>(
            value: selectedYear,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            dropdownColor: Theme.of(context).primaryColor,
            style: const TextStyle(color: Colors.white),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('すべて'),
              ),
              ...availableYears.map((year) => DropdownMenuItem<int?>(
                    value: year,
                    child: Text('$year年'),
                  )),
            ],
            onChanged: (value) {
              ref.read(selectedYearProvider.notifier).setYear(value);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // カテゴリフィルター
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('すべて'),
                  selected: selectedCategory == null,
                  onSelected: (_) {
                    ref.read(selectedCategoryProvider.notifier).setCategory(null);
                  },
                ),
                const SizedBox(width: 4),
                ...TaskCategory.values.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: FilterChip(
                        label: Text(category.displayName),
                        selected: selectedCategory == category,
                        onSelected: (_) {
                          ref.read(selectedCategoryProvider.notifier).setCategory(
                              selectedCategory == category ? null : category);
                        },
                      ),
                    )),
              ],
            ),
          ),

          // 進捗バー部分
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '達成率 ${(completionRate * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Divider(),

          // タスク一覧
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text('タスクがありません\n+ボタンで追加しましょう',
                        textAlign: TextAlign.center),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskTile(
                        task: task,
                        onToggle: () => notifier.toggleTaskComplete(task.id),
                        onDelete: () async {
                          final confirmed =
                              await _showDeleteConfirmDialog(context, task.title);
                          if (confirmed == true) {
                            notifier.removeTask(task.id);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<AddTaskResult>(
            context: context,
            builder: (context) => const AddTaskDialog(),
          );
          if (result != null && result.title.isNotEmpty) {
            notifier.addTask(
              result.title,
              year: result.year,
              category: result.category,
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(
      BuildContext context, String taskTitle) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('タスクを削除'),
          content: Text('「$taskTitle」を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }
}
