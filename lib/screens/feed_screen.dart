import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_item_screen.dart';
import 'item_detail_screen.dart'; // Optional detail screen

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<dynamic> items = [];

  String selectedStatus = 'all'; // Filter: all, lost, found

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);

    final response = await supabase
        .from('items')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      items = response;
      isLoading = false;
    });
  }

  // Filtered items based on selected status
  List<dynamic> get filteredItems {
    if (selectedStatus == 'all') return items;
    return items.where((item) => item['status'] == selectedStatus).toList();
  }

  // Navigate to Post Item screen
  void _navigateToAddItem() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PostItemScreen()))
        .then((_) => loadItems());
  }

  // Staff access logic
  void _staffAccess() {
    // TODO: Replace with PIN auth + staff UI later
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Staff Access"),
        content: const Text("Staff-only features will go here."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close")),
        ],
      ),
    );
  }

  // Navigate to Item Detail
  void _navigateToItemDetail(dynamic item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Lost & Found"),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: "Staff Access",
            onPressed: _staffAccess,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: selectedStatus == 'all',
                  onSelected: (_) => setState(() => selectedStatus = 'all'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Lost'),
                  selected: selectedStatus == 'lost',
                  onSelected: (_) => setState(() => selectedStatus = 'lost'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Found'),
                  selected: selectedStatus == 'found',
                  onSelected: (_) => setState(() => selectedStatus = 'found'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredItems.isEmpty
          ? const Center(child: Text("No items found"))
          : Padding(
        padding: const EdgeInsets.all(4),
        child: GridView.builder(
          itemCount: filteredItems.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return GestureDetector(
              onTap: () => _navigateToItemDetail(item),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: item['image_url'] != null
                        ? Image.network(
                      item['image_url'],
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                          Icons.image_not_supported),
                    ),
                  ),
                  if (item['status'] != null ||
                      item['is_claimed'] == true)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        color: Colors.black.withOpacity(0.5),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['status'] == 'lost'
                                  ? 'Lost'
                                  : 'Found',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12),
                            ),
                            if (item['is_claimed'] == true)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.greenAccent,
                                size: 14,
                              )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddItem,
        tooltip: "Add Item",
        child: const Icon(Icons.add),
      ),
    );
  }
}
