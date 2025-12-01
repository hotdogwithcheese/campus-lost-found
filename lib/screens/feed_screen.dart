import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import 'post_item_screen.dart';
import 'item_detail_screen.dart';

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
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    bool hasInternet = false;

    // ✅ Real internet check
    try {
      final result = await http.get(Uri.parse('https://google.com')).timeout(const Duration(seconds: 5));
      hasInternet = result.statusCode == 200;
    } catch (_) {
      hasInternet = false;
    }

    if (hasInternet) {
      try {
        final response = await supabase
            .from(SupabaseConfig.itemsTableName)
            .select()
            .order('created_at', ascending: false);

        if (response != null) {
          items = List.from(response);
          await prefs.setString('cached_items', jsonEncode(items));
        }
      } catch (_) {
        hasInternet = false;
      }
    }

    if (!hasInternet) {
      final cached = prefs.getString('cached_items');
      if (cached != null) {
        items = jsonDecode(cached);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offline mode: showing cached items')),
          );
        });
      } else {
        items = [];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load items')),
          );
        });
      }
    }

    setState(() => isLoading = false);
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
          decoration: const InputDecoration(labelText: 'Enter Staff PIN'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
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
      setState(() => isStaff = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff mode activated')),
      );
    }

    _pinController.clear();
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ['All', 'Lost', 'Found', 'Claimed'].map((s) {
                return ChoiceChip(
                  label: Text(s),
                  selected: s == selectedStatus,
                  onSelected: (_) => setState(() => selectedStatus = s),
                  selectedColor: Colors.blue,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: categories.map((c) {
                return ChoiceChip(
                  label: Text(c),
                  selected: c == selectedCategory,
                  onSelected: (_) => setState(() => selectedCategory = c),
                  selectedColor: Colors.blue,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
            )
          ],
        ),
      ),
    );
  }

  void _navigateToPostItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostItemScreen()),
    );
    await loadItems();
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
              : item['status']?.toString().toLowerCase() ==
              selectedStatus.toLowerCase());

      final categoryMatch = selectedCategory == 'All' ||
          item['category']?.toString().trim().toLowerCase() ==
              selectedCategory.toLowerCase();

      return statusMatch && categoryMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Lost & Found", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!isStaff)
            IconButton(icon: const Icon(Icons.admin_panel_settings), onPressed: _showStaffPinDialog),
          if (isStaff)
            TextButton(
              onPressed: () {
                setState(() => isStaff = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exited staff mode')),
                );
              },
              child: const Text('Exit', style: TextStyle(color: Colors.white)),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadItems),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['All', 'Lost', 'Found', 'Claimed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedStatus = v!),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(),
                      labelText: 'Status',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedCategory = v!),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(),
                      labelText: 'Category',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.filter_list), onPressed: _openFilterModal),
              ],
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text("No items found"))
                : LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = _calculateCrossAxisCount(width);
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailScreen(
                            item: item,
                            isStaff: isStaff,
                          ),
                        ),
                      );
                      await loadItems();
                    },
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 8,
                            child: item['image_url'] != null
                                ? Image.network(
                              item['image_url'],
                              fit: BoxFit.cover,
                            )
                                : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported, size: 50),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            color: Colors.grey.shade100,
                            child: Column(
                              children: [
                                Text(
                                  item['title'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${item['category'] ?? 'Uncategorized'} • ${item['status'] == 'lost' ? 'Lost' : 'Found'}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                if (item['is_claimed'] == true)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Chip(
                                      label: Text("Claimed"),
                                      backgroundColor: Colors.green,
                                      labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
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
            }),
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
