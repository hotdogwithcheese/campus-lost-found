import 'package:flutter/material.dart';
import 'post_item_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String selectedFilter = "All"; // "All", "Lost", "Found"

  final List<Map<String, String>> items = [
    {"name": "Blue Backpack", "status": "Lost", "location": "Library"},
    {"name": "Black Umbrella", "status": "Found", "location": "Cafeteria"},
    {"name": "Keys", "status": "Lost", "location": "Lecture Hall"},
    {"name": "Red Jacket", "status": "Found", "location": "Gym"},
    {"name": "Water Bottle", "status": "Lost", "location": "Lobby"},
    {"name": "Notebook", "status": "Found", "location": "Library"},
    {"name": "Scarf", "status": "Lost", "location": "Gym"},
    {"name": "Hat", "status": "Found", "location": "Cafeteria"},
  ];

  List<Map<String, String>> get filteredItems {
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
                    onPressed: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
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
                crossAxisCount: 3,        // 3 columns
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,   // height vs width ratio
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
                            child: const Center(
                              child: Icon(Icons.image, size: 30, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${item['status']} • ${item['location']!}",
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item['status'] == 'Lost')
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green, size: 20),
                            tooltip: 'Mark as Claimed',
                            onPressed: () {
                              setState(() {
                                item['status'] = 'Claimed';
                              });
                            },
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
