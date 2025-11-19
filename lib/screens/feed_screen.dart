import 'package:flutter/material.dart';
import 'post_item_screen.dart';
import 'staff_access_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Example item list
  List<Map<String, dynamic>> items = [
    {
      'title': 'Lost Wallet',
      'category': 'Accessories',
      'status': 'lost',
      'isClaimed': false,
    },
    {
      'title': 'Found Book',
      'category': 'Books',
      'status': 'found',
      'isClaimed': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Lost & Found'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Staff Access',
            onPressed: () {
              // Navigate to StaffAccessScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => StaffAccessScreen(items: items)),
              );
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text("No items found"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(item['title']),
              subtitle: Text(
                "${item['category']} • ${item['status'] == 'lost' ? 'Lost Item' : 'Found Item'}",
              ),
              trailing: item['isClaimed']
                  ? const Chip(
                label: Text("Claimed"),
                backgroundColor: Colors.greenAccent,
              )
                  : null,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PostItemScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Post Item',
      ),
    );
  }
}
