import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/wishlist.dart';

final wishListProvider = StateNotifierProvider<WishListNotifier, List<WishList>>(
  (ref) => WishListNotifier(),
);

class WishListNotifier extends StateNotifier<List<WishList>> {
  WishListNotifier() : super([]);

  final _uuid = Uuid();

  void addWishList(String title, DateTime deadLine) {
    final newWishList = WishList(
      id: _uuid.v4(),
      title: title, 
      deadline: deadLine,
      tasks: [],
    );
    state = [...state, newWishList];
  }

  void deleteWishList(String id) {
    state = state.where((wish) => wish.id != id).toList();
  }

}