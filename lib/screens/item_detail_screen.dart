import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';

class ItemDetailScreen extends StatefulWidget {
  final dynamic item;
  final bool isStaff;
  const ItemDetailScreen({super.key, required this.item, required this.isStaff});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final supabase = SupabaseConfig.client;
  bool isLoading = false;
  late dynamic currentItem;

  @override
  void initState() {
    super.initState();
    currentItem = Map<String, dynamic>.from(widget.item);
  }

  Future<void> _toggleClaim() async {
    if (!widget.isStaff) return;

    setState(() => isLoading = true);
    final wantClaim = !(currentItem['is_claimed'] == true);

    try {
      await supabase.rpc('staff_action', params: {
        'secret_code': '1234',
        'action_type': 'update',
        'item_id': currentItem['id'],
      });

      setState(() => currentItem['is_claimed'] = wantClaim);

      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_items');
      if (cached != null) {
        final list = jsonDecode(cached) as List<dynamic>;
        final idx = list.indexWhere((e) => e['id'] == currentItem['id']);
        if (idx >= 0) {
          list[idx]['is_claimed'] = wantClaim;
          await prefs.setString('cached_items', jsonEncode(list));
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(wantClaim ? 'Item marked as claimed' : 'Item unclaimed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteItem() async {
    if (!widget.isStaff) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      await supabase.rpc('staff_action', params: {
        'secret_code': '1234',
        'action_type': 'delete',
        'item_id': currentItem['id'],
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = currentItem;

    return Scaffold(
      appBar: AppBar(
        title: Text(item['title'] ?? 'Item Detail', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item['image_url'] != null
                        ? Image.network(
                      item['image_url'],
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 0.6,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 0.6,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, size: 100),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(item['title'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text("Category: ${item['category'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Status: ${item['status'] == 'lost' ? 'Lost' : 'Found'}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  if (item['is_claimed'] == true)
                    const Chip(label: Text("Claimed"), backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white, fontSize: 12)),
                  const SizedBox(height: 16),
                  Align(alignment: Alignment.centerLeft, child: Text('Description:', style: const TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  Text(item['description'] ?? 'No description'),
                  const SizedBox(height: 24),
                  if (widget.isStaff)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item['is_claimed'] == true ? Colors.blue : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: isLoading ? null : _toggleClaim,
                            child: isLoading
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : Text(item['is_claimed'] == true ? 'Unclaim' : 'Claim'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: isLoading ? null : _deleteItem,
                            child: isLoading
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
