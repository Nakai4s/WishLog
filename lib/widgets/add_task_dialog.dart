import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/year_provider.dart';

class AddTaskResult {
  final String title;
  final int? year;
  final TaskCategory? category;

  AddTaskResult({
    required this.title,
    this.year,
    this.category,
  });
}

class AddTaskDialog extends ConsumerStatefulWidget {
  const AddTaskDialog({super.key});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _titleController = TextEditingController();
  int? _selectedYear;
  TaskCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // デフォルトで現在選択中の年度を設定
    _selectedYear = ref.read(selectedYearProvider);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableYears = ref.watch(availableYearsProvider);

    return AlertDialog(
      title: const Text('新しいタスク'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タスク名を入力',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _selectedYear,
              decoration: const InputDecoration(
                labelText: '年度',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('指定なし'),
                ),
                ...availableYears.map((year) => DropdownMenuItem<int?>(
                      value: year,
                      child: Text('$year年'),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskCategory?>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'カテゴリ',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<TaskCategory?>(
                  value: null,
                  child: Text('指定なし'),
                ),
                ...TaskCategory.values.map((category) =>
                    DropdownMenuItem<TaskCategory?>(
                      value: category,
                      child: Text(category.displayName),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              Navigator.pop(
                context,
                AddTaskResult(
                  title: _titleController.text,
                  year: _selectedYear,
                  category: _selectedCategory,
                ),
              );
            }
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}
