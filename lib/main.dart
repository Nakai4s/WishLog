import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:hive/hive.dart";
import 'package:path_provider/path_provider.dart';
import 'package:wishlog/models/task.dart';
import 'package:wishlog/models/wishlist.dart';
import 'screens/wishlist_list_screen.dart';

void main() async {
  // フラッターエンジンの初期化(非同期処理を行う前に必要)
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  Hive.registerAdapter(WishListAdapter());
  Hive.registerAdapter(TaskAdapter());

  await Hive.openBox<WishList>('wishlists');

  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WishLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: '851MkPOP',
      ),
      home: const WishListListScreen(),
    );
  }
}
