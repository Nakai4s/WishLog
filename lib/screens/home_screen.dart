// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wishlist_provider.dart';
import '../providers/year_provider.dart';
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
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    final notifier = ref.read(wishListProvider.notifier);
    final selectedYear = ref.read(selectedYearProvider);

    if (selectedYear == null) return;

    notifier.addTask(
      title,
      year: selectedYear,
    );
    _taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(wishListProvider.notifier);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final yearTasks = ref.watch(yearTasksProvider);
    final completionRate = ref.watch(filteredCompletionRateProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final availableYears = ref.watch(availableYearsProvider);
    final statusFilter = ref.watch(statusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ウィッシュログ'),
      ),
      body: Column(
        children: [
          // 年度選択ドロップダウン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '年度',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedYear ?? DateTime.now().year,
                  isDense: true,
                  isExpanded: true,
                  items: availableYears.map((year) => DropdownMenuItem<int>(
                        value: year,
                        child: Text('$year年'),
                      )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(selectedYearProvider.notifier).setYear(value);
                    }
                  },
                ),
              ),
            ),
          ),
          const Divider(),

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
              '${yearTasks.where((t) => t.isCompleted).length} / ${yearTasks.length} 完了',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          // ステータスフィルター
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('すべて'),
                  selected: statusFilter == StatusFilter.all,
                  onSelected: (_) {
                    ref.read(statusFilterProvider.notifier).setFilter(StatusFilter.all);
                  },
                ),
                const SizedBox(width: 4),
                FilterChip(
                  label: const Text('未完了'),
                  selected: statusFilter == StatusFilter.incomplete,
                  onSelected: (_) {
                    ref.read(statusFilterProvider.notifier).setFilter(StatusFilter.incomplete);
                  },
                ),
                const SizedBox(width: 4),
                FilterChip(
                  label: const Text('完了'),
                  selected: statusFilter == StatusFilter.completed,
                  onSelected: (_) {
                    ref.read(statusFilterProvider.notifier).setFilter(StatusFilter.completed);
                  },
                ),
              ],
            ),
          ),

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
                        onToggle: () => notifier.toggleTaskComplete(
                            task.id, selectedYear ?? DateTime.now().year),
                        onDelete: () => notifier.removeTask(
                            task.id, selectedYear ?? DateTime.now().year),
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
}
