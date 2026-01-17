// lib/screens/wishlist_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/task_tile.dart';
import '../models/wishlist.dart';

class WishListDetailScreen extends ConsumerWidget {
  final String wishListId;

  const WishListDetailScreen({super.key, required this.wishListId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishLists = ref.watch(wishListProvider);
    final notifier = ref.read(wishListProvider.notifier);
    WishList? foundWish;
    for (var w in wishLists) {
      if (w.id == wishListId) {
        foundWish = w;
        break;
      }
    }
    if (foundWish == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ウィッシュが見つかりません'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('一覧に戻る'),
          ),
        ),
      );
    }
    final wish = foundWish;
    return Scaffold(
      appBar: AppBar(
        title: Text(wish.title),
      ),
      body: Column(
        children: [
          // 進捗バー部分
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
              value: wish.completionRate,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '達成率 ${(wish.completionRate * 100).toStringAsFixed(0)}% ・ 残り ${wish.remainingDays} 日',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Divider(),

          // タスク一覧
          Expanded(
            child: ListView.builder(
              itemCount: wish.tasks.length,
              itemBuilder: (context, index) {
                final task = wish.tasks[index];
                return TaskTile(
                  task: task,
                  onToggle: () => notifier.toggleTaskComplete(wish.id, task.id),
                  onDelete: () async {
                    final confirmed = await _showDeleteConfirmDialog(context, task.title);
                    if (confirmed == true) {
                      notifier.removeTask(wish.id, task.id);
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
          final newTitle = await _showAddTaskDialog(context);
          if (newTitle != null && newTitle.isNotEmpty) {
            notifier.addTaskToWishList(wish.id, newTitle);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showAddTaskDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新しいタスク'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'タスク名を入力'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, String taskTitle) async {
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
