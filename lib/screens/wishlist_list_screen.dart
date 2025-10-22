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
        onPressed: () async {
          // 簡易追加（実際はダイアログやフォームが必要）
          final now = DateTime.now();
          await notifier.addWishList('新しい願い', now.add(const Duration(days: 30)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
