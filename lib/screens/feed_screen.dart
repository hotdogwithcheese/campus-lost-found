import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'post_item_screen.dart'; // Make sure this path is correct

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final supabase = SupabaseConfig.client;
  bool isLoading = true;
  List<dynamic> items = [];

  // Staff mode
  bool isStaff = false;
  final String staffPin = "1234"; // placeholder PIN
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);
    final response = await supabase
        .from(SupabaseConfig.itemsTableName)
        .select()
        .order('created_at', ascending: false);

    setState(() {
      items = response;
      isLoading = false;
    });
  }

  Future<void> deleteItem(String id, int index) async {
    await supabase.from(SupabaseConfig.itemsTableName).delete().eq('id', id);
    setState(() => items.removeAt(index));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Item deleted')));
  }

  void _showStaffPinDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Staff Access'),
        content: TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter Staff PIN',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_pinController.text == staffPin) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect PIN')),
                );
              }
            },
            child: const Text('Enter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        isStaff = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff mode activated')),
      );
      _pinController.clear();
    }
  }

  void _navigateToPostItem() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PostItemScreen()),
    );
    loadItems(); // Refresh feed after posting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Lost & Found"),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Staff Access',
            onPressed: _showStaffPinDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("No items found"))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.7,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return Card(
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: item['image_url'] != null
                      ? Image.network(item['image_url'], fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, size: 50),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Text(item['title'],
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(
                        "${item['category']} • ${item['status'] == 'lost' ? 'Lost' : 'Found'}",
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey),
                      ),
                      if (item['is_claimed'] == true)
                        const Chip(
                          label: Text("Claimed"),
                          backgroundColor: Colors.greenAccent,
                        ),
                      if (isStaff)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  textStyle: const TextStyle(fontSize: 10)),
                              onPressed: () async {
                                // Mark as claimed
                                await supabase
                                    .from(SupabaseConfig.itemsTableName)
                                    .update({'is_claimed': true})
                                    .eq('id', item['id']);
                                setState(
                                        () => items[index]['is_claimed'] = true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                        Text('Item marked as claimed')));
                              },
                              child: const Text('Claimed'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              onPressed: () async {
                                final confirmed =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete item?'),
                                    content: const Text(
                                        'This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete')),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await deleteItem(item['id'], index);
                                }
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPostItem,
        child: const Icon(Icons.add),
        tooltip: 'Post New Item',
      ),
    );
  }
}
