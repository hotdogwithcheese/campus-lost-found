import 'package:flutter/material.dart';
import 'post_item_screen.dart';

class FeedScreen extends StatefulWidget {
  final bool isStaff;
  // Pass true if the user is a staff member
  // Example: FeedScreen(isStaff: true)

  const FeedScreen({super.key, this.isStaff = false});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String selectedFilter = "All"; // All | Lost | Found | Claimed

  /// 🔥 EMPTY LIST — Rexie will fill this with real database data later.
  ///
  /// Format expected:
  /// [
  ///    { "id": "123", "name": "...", "status": "Lost", "location": "...", "image": "..."},
  /// ]
  List<Map<String, dynamic>> items = [];

  List<Map<String, dynamic>> get filteredItems {
    if (selectedFilter == "All") return items;
    return items.where((item) => item['status'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Feed'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // FILTER BUTTONS
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ["All", "Lost", "Found", "Claimed"].map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => selectedFilter = filter);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isSelected ? Colors.blue : Colors.grey.shade300,
                      foregroundColor:
                      isSelected ? Colors.white : Colors.black,
                    ),
                    child: Text(filter),
                  ),
                );
              }).toList(),
            ),
          ),

          // EMPTY STATE
          if (filteredItems.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "No items to display.",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ),
            ),

          // GRID
          if (filteredItems.isNotEmpty)
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        children: [
                          // IMAGE
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: item["image"] != null
                                    ? Image.network(item["image"], fit: BoxFit.cover)
                                    : const Center(
                                  child: Icon(Icons.image, size: 30, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // NAME
                          Text(
                            item['name'] ?? 'Unnamed Item',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // STATUS + LOCATION
                          Text(
                            "${item['status']} • ${item['location']}",
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // STAFF ONLY ACTIONS
                          if (widget.isStaff) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // UPDATE STATUS
                                IconButton(
                                  icon: const Icon(Icons.update, size: 20, color: Colors.blue),
                                  tooltip: 'Update Status',
                                  onPressed: () {
                                    // TODO: Rexie will update status in Supabase
                                    print("Staff wants to update status of ${item['id']}");
                                  },
                                ),

                                // DELETE ITEM
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  tooltip: 'Delete Item',
                                  onPressed: () {
                                    // TODO: Rexie will delete item from Supabase
                                    print("Staff wants to DELETE ${item['id']}");
                                  },
                                ),
                              ],
                            ),
                          ],
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostItemScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
