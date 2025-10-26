import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishlog/screens/wishlist_detail_screen.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/wishlist_tile.dart';

// ウィッシュリスト一覧画面
class WishListListScreen extends ConsumerWidget {
  const WishListListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishLists = ref.watch(wishListProvider);
    final notifier = ref.read(wishListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ウィッシュログ'),
      ),
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
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('確認'),
                    content: Text('${wish.title}を削除しますか？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          notifier.deleteWishListById(wish.id);
                        },
                        child: const Text('削除'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
          _showAddWishDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // タイトルと期日を入力するダイアログを表示
  Future<void> _showAddWishDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'ウィッシュリスト名'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: DateTime(now.year + 1),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });                    
                    }
                  },
                  child: const Text('期限を選択'),
                ),
                const SizedBox(height: 10),              
                // 期日の表示
                Text(
                  selectedDate == null
                      ? '期日：未選択'
                      : '期日：${selectedDate!.toLocal().toString().split(' ')[0]}',
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
                  if(titleController.text.isNotEmpty && selectedDate != null){
                    ref.read(wishListProvider.notifier)
                      .addWishList(titleController.text, selectedDate!);
                    Navigator.pop(context);
                  }
                },
                child: const Text('追加'),
              ),
            ],
          );
        });
      },
    );
  }
}