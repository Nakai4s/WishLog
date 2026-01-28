// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/wishlist_provider.dart';
import '../providers/year_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.isEmpty) return;

    final notifier = ref.read(wishListProvider.notifier);
    final selectedYear = ref.read(selectedYearProvider);
    final selectedCategory = ref.read(selectedCategoryProvider);

    notifier.addTask(
      _taskController.text,
      year: selectedYear,
      category: selectedCategory,
    );
    _taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Text('タスクがありません\n下の入力欄から追加しましょう',
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

          // タスク入力欄
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        hintText: 'タスクを入力...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _addTask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addTask,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
        ],
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
