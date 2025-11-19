import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  final dynamic item; // item data passed from feed

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['title'] ?? "Item Detail"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            item['image_url'] != null
                ? Image.network(item['image_url'])
                : const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(height: 20),
            Text(
              item['title'] ?? "",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Category: ${item['category'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Status: ${item['status'] == 'lost' ? 'Lost' : 'Found'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (item['is_claimed'] == true)
              const Chip(
                label: Text("Claimed"),
                backgroundColor: Colors.greenAccent,
              ),
          ],
        ),
      ),
    );
  }
}
