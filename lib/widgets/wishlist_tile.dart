import 'package:flutter/material.dart';
import '../models/wishlist.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class WishListTile extends StatelessWidget {
  final WishList wish;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const WishListTile({
    Key? key,
    required this.wish,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percent = wish.completionRate.clamp(0.0, 1.0);
    final remaining = wish.remainingDays;

    return Card(
      child: ListTile(
        title: Text(wish.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: percent,
              progressColor: Colors.green,
              backgroundColor: Colors.grey[300],
              animation: true,
            ),
            const SizedBox(height: 4),
            Text(
              '達成率 ${(percent * 100).round()}% ・残り ${remaining}日',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
