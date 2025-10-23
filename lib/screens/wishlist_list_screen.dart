import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishlog/screens/wishlist_detail_screen.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/wishlist_tile.dart';

class WishListListScreen extends ConsumerWidget {
  const WishListListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishLists = ref.watch(wishListProvider);
    final notifier = ref.read(wishListProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('WishLog')),
      body: ListView.builder(
        itemCount: wishLists.length,
        itemBuilder: (context, index) {
          final wish = wishLists[index];
          return WishListTile(
            wish: wish,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WishListDetailScreen(wishListId: wish.id),
                ),
              );
            },
            onDelete: () {
              notifier.deleteWishListById(wish.id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
          // 簡易追加（実際はダイアログやフォームが必要）
          // final now = DateTime.now();
          // await notifier.addWishList('新しい願い', now.add(const Duration(days: 30)));
          _showAddWishDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddWishDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新しいウィッシュ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'タイトル'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
                child: const Text('期限を選択'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedDate != null) {
                  ref.read(wishListProvider.notifier)
                      .addWishList(titleController.text, selectedDate!);
                  Navigator.pop(context);
                }
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }
}
