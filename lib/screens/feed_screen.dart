import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_item_screen.dart';

class Item {
  final String id;
  final String name;
  String status;
  final String location;
  final String? imageUrl;

  Item({
    required this.id,
    required this.name,
    required this.status,
    required this.location,
    this.imageUrl,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'].toString(),
      name: map['name'] as String,
      status: map['status'] as String,
      location: map['location'] as String,
      imageUrl: map['image_url'] as String?,
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String selectedFilter = "All"; // "All", "Lost", "Found"
  List<Item> items = [];
  bool isLoading = true;
  bool isStaff = false;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  // Fetch items from Supabase
  Future<void> fetchItems() async {
    try {
      final List<dynamic> data = await Supabase.instance.client
          .from('items')
          .select()
          .order('created_at', ascending: false);

      final fetched = data.map((e) => Item.fromMap(e as Map<String, dynamic>)).toList();

      setState(() {
        items = fetched;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching items: $e');
      setState(() => isLoading = false);
    }
  }

  // Filter items, hide claimed if not staff
  List<Item> get filteredItems {
    var list = items.where((item) => item.status != 'Claimed' || isStaff).toList();
    if (selectedFilter == "All") return list;
    return list.where((item) => item.status == selectedFilter).toList();
  }

  // Staff actions
  Future<void> markAsClaimed(Item item) async {
    try {
      await Supabase.instance.client
          .from('items')
          .update({'status': 'Claimed'})
          .eq('id', item.id);

      setState(() => item.status = 'Claimed');
    } catch (e) {
      print('Error marking as claimed: $e');
    }
  }

  Future<void> deleteItem(Item item) async {
    try {
      await Supabase.instance.client
          .from('items')
          .delete()
          .eq('id', item.id);

      setState(() => items.remove(item));
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  // Staff password check
  void checkStaffPassword(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Staff Access'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter staff password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (passwordController.text == '1234') {
                  setState(() => isStaff = true);
                  Navigator.of(ctx).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect password')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Feed'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => checkStaffPassword(context),
            tooltip: 'Staff Login',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Filter buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ["All", "Lost", "Found"].map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedFilter = filter),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    child: Text(filter),
                  ),
                );
              }).toList(),
            ),
          ),

          // Grid of items
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: item.imageUrl != null
                                  ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                                  : const Center(child: Icon(Icons.image, size: 30, color: Colors.grey)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${item.status} • ${item.location}",
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Staff-only buttons
                        if (isStaff && item.status != 'Claimed')
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green, size: 20),
                            tooltip: 'Mark as Claimed',
                            onPressed: () => markAsClaimed(item),
                          ),
                        if (isStaff)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            tooltip: 'Delete Post',
                            onPressed: () => deleteItem(item),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostItemScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
