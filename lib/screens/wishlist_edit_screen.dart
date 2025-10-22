import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wishlist_provider.dart';

class WishListEditScreen extends ConsumerStatefulWidget {
  final int wishKey;
  final String initialTitle;
  final DateTime initialDeadline;

  const WishListEditScreen({
    super.key,
    required this.wishKey,
    required this.initialTitle,
    required this.initialDeadline,
  });

  @override
  ConsumerState<WishListEditScreen> createState() => _WishListEditScreenState();
}

class _WishListEditScreenState extends ConsumerState<WishListEditScreen> {
  late TextEditingController _titleController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _selectedDate = widget.initialDeadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    ref.read(wishListProvider.notifier).updateWishListById(
      widget.wishKey.toString(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ウィッシュリスト編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '期限: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('日付を選択'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
