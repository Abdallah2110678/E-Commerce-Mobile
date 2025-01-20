import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_project/models/product.dart';

class RatingsDetailsPage extends StatelessWidget {
  final Product product;

  const RatingsDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate star ratings breakdown
    final Map<int, int> starCounts = {
      5: 0,
      4: 0,
      3: 0,
      2: 0,
      1: 0,
    };

    for (var ratingComment in product.ratingComments) {
      final rating = ratingComment.rating.toInt();
      if (starCounts.containsKey(rating)) {
        starCounts[rating] = starCounts[rating]! + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Display breakdown of ratings
            ...starCounts.entries.map((entry) {
              final star = entry.key; // Number of stars
              final count = entry.value; // Count of ratings for this star

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(star, (index) {
                      return const Icon(Icons.star,
                          color: Colors.amber, size: 16);
                    }), // Display stars based on the number
                  ),
                  Text('$count'),
                ],
              );
            }).toList(),

            const Divider(height: 32),

            const Text(
              'All Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Display all reviews
            Expanded(
              child: ListView.builder(
                itemCount: product.ratingComments.length,
                itemBuilder: (context, index) {
                  final ratingComment = product.ratingComments[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          ratingComment.userName[0], // User's initial
                        ),
                      ),
                      title: Text(ratingComment.userName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ratingComment.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(ratingComment.comment),
                        ],
                      ),
                      trailing: Text(
                        DateFormat('dd MMM yyyy')
                            .format(ratingComment.timestamp),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
