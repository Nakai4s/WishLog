import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/category.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.health:
        return Colors.green;
      case TaskCategory.hobby:
        return Colors.purple;
      case TaskCategory.relationship:
        return Colors.pink;
      case TaskCategory.money:
        return Colors.amber;
      case TaskCategory.learning:
        return Colors.teal;
      case TaskCategory.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: task.isCompleted,
      onChanged: (_) => onToggle(),
      controlAffinity: ListTileControlAffinity.leading,
      title: Row(
        children: [
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (task.category != null)
            Chip(
              label: Text(
                task.category!.displayName,
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: _getCategoryColor(task.category!),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
      secondary: IconButton(
        icon: const Icon(Icons.delete_sweep),
        onPressed: () => onDelete(),
      ),
    );
  }
}
