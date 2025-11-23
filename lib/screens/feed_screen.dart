import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import 'post_item_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final supabase = SupabaseConfig.client;
  bool isLoading = true;
  List<dynamic> items = [];

  bool isStaff = false;
  final String staffPin = "1234";
  final TextEditingController _pinController = TextEditingController();

  String selectedStatus = 'All';
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Electronics',
    'Bags',
    'Books',
    'Clothing',
    'Accessories',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    bool online = false;

    try {
      final response = await supabase
          .from(SupabaseConfig.itemsTableName)
          .select()
          .order('created_at', ascending: false);

      items = response;
      online = true;

      // Save offline cache
      prefs.setString('cached_items', jsonEncode(items));
    } catch (_) {
      // Offline: read cached items
      final cached = prefs.getString('cached_items');
      if (cached != null) {
        items = jsonDecode(cached);

        // Show SnackBar after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offline mode: showing cached items')),
          );
        });
      } else {
        items = [];
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> deleteItem(String id, int index) async {
    await supabase.from(SupabaseConfig.itemsTableName).delete().eq('id', id);
    setState(() => items.removeAt(index));

    // Update offline cache
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cached_items', jsonEncode(items));

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Item deleted')));
  }

  void _showStaffPinDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Staff Access', style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter Staff PIN',
            labelStyle: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (_pinController.text == staffPin) Navigator.pop(context, true);
              else {
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
      setState(() => isStaff = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Staff mode activated')));
      _pinController.clear();
    }
  }

  void _navigateToPostItem() async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PostItemScreen()));
    loadItems();
  }

  Widget _buildFilters() {
    final statusOptions = ['All', 'Lost', 'Found', 'Claimed'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: statusOptions.map((status) {
              final selected = selectedStatus == status;
              return ChoiceChip(
                label: Text(status),
                selected: selected,
                onSelected: (_) => setState(() => selectedStatus = status),
                selectedColor: Colors.blue,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: categories.map((cat) {
              final selected = selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (_) => setState(() => selectedCategory = cat),
                selectedColor: Colors.blue,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width > 1200) return 5;
    if (width > 800) return 4;
    if (width > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) {
      final statusMatch = selectedStatus == 'All' ||
          (selectedStatus == 'Claimed'
              ? item['is_claimed'] == true
              : item['status'].toString().toLowerCase() ==
              selectedStatus.toLowerCase());
      final categoryMatch = selectedCategory == 'All' ||
          item['category']?.toString().trim().toLowerCase() ==
              selectedCategory.toLowerCase();
      return statusMatch && categoryMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Lost & Found"),
        actions: [
          IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: _showStaffPinDialog),
        ],
      ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.blue))
          : Column(
        children: [
          _buildFilters(),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text("No items found"))
                : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount =
                _calculateCrossAxisCount(constraints.maxWidth);
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return InkWell(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(item['title']),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                if (item['image_url'] != null)
                                  Image.network(item['image_url']),
                                const SizedBox(height: 8),
                                Text('Category: ${item['category']}'),
                                Text(
                                  'Status: ${item['status'] == 'lost' ? 'Lost' : 'Found'}',
                                  style: const TextStyle(
                                      color: Colors.blue),
                                ),
                                if (item['is_claimed'] == true)
                                  const Chip(
                                      label: Text("Claimed",
                                          style: TextStyle(
                                              color: Colors.white)),
                                      backgroundColor: Colors.blue),
                                const SizedBox(height: 8),
                                const Text('Description:'),
                                Text(item['description'] ??
                                    'No description'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context),
                                child: const Text('Close')),
                          ],
                        ),
                      ),
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: item['image_url'] != null
                                  ? Image.network(
                                  item['image_url'],
                                  fit: BoxFit.cover)
                                  : const Icon(
                                  Icons.image_not_supported,
                                  size: 50),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  Text(item['title'],
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow.ellipsis),
                                  Text(
                                    "${item['category']} • ${item['status'] == 'lost' ? 'Lost' : 'Found'}",
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue),
                                  ),
                                  if (item['is_claimed'] == true)
                                    const Chip(
                                        label: Text("Claimed",
                                            style: TextStyle(
                                                color: Colors.white)),
                                        backgroundColor: Colors.blue),
                                  if (isStaff)
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                            Colors.blue,
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal: 8,
                                                vertical: 2),
                                            textStyle:
                                            const TextStyle(
                                                fontSize: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.zero,
                                            ),
                                          ),
                                          onPressed: () async {
                                            await supabase
                                                .from(SupabaseConfig
                                                .itemsTableName)
                                                .update({
                                              'is_claimed': true
                                            })
                                                .eq(
                                                'id',
                                                item[
                                                'id']);
                                            setState(() =>
                                            item['is_claimed'] =
                                            true);

                                            // Update offline cache
                                            final prefs = await SharedPreferences.getInstance();
                                            prefs.setString('cached_items', jsonEncode(items));

                                            ScaffoldMessenger.of(
                                                context)
                                                .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Item marked as claimed')));
                                          },
                                          child: const Text(
                                              'Claimed',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20),
                                          onPressed: () async {
                                            final confirmed =
                                            await showDialog<
                                                bool>(
                                              context: context,
                                              builder: (_) =>
                                                  AlertDialog(
                                                    title: const Text(
                                                        'Delete item?'),
                                                    content:
                                                    const Text(
                                                        'This action cannot be undone.'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  false),
                                                          child: const Text(
                                                              'Cancel')),
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  true),
                                                          child: const Text(
                                                              'Delete')),
                                                    ],
                                                  ),
                                            );

                                            if (confirmed == true)
                                              await deleteItem(
                                                  item['id'],
                                                  index);
                                          },
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPostItem,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Post New Item',
        backgroundColor: Colors.blue,
      ),
    );
  }
}
