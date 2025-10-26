import 'package:flutter/material.dart';
import '../models/wishlist.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class WishListTile extends StatelessWidget {
  final WishList wish;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const WishListTile({
    super.key,
    required this.wish,
    required this.onTap,
    required this.onDelete,
  });

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
            const SizedBox(height: 4),
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: percent,
              progressColor: Colors.green,
              backgroundColor: Colors.grey[300],
              animation: false,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 4),
            Text(
              '達成率 ${(percent * 100).round()}% ・残り $remaining日',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_sweep),
          onPressed: onDelete,
          padding: EdgeInsets.zero,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(vertical:1.0, horizontal:16.0),
      ),
    );
  }
}
