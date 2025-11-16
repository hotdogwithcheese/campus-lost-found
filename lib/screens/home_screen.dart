// Path: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/item_model.dart';
import '../services/supabase_service.dart';
import '../widgets/staff_mode_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    // Start fetching items as soon as the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ⚠️ ERROR POINT 1: Calls fetchItems(). If this fails (due to a bad SQL query or ItemModel.fromJson), the screen will go red.
      Provider.of<SupabaseService>(context, listen: false).fetchItems();
    });
  }

  void _showStaffDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Dialog for staff to enter the passcode
        return const StaffModeDialog();
      },
    );
  }

  void _confirmAndDelete(BuildContext context, ItemModel item, String passcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${item.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop(); // Close confirmation dialog

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting item...')),
              );

              // ⚠️ ERROR POINT 2: Calls staffDeleteItem(). If this function is missing
              // or its internal RPC/SQL logic is wrong (e.g., 'staffdelete' column error), it will fail.
              final success = await Provider.of<SupabaseService>(context, listen: false)
                  .staffDeleteItem(item.id!, passcode); // item.id! might crash if id is null

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Item deleted successfully.' : 'Deletion failed! Check passcode and connection.'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the AppState for staff mode status
    final appState = Provider.of<AppState>(context);

    // 2. Listen to the SupabaseService for the list of items
    final supabaseService = Provider.of<SupabaseService>(context);

    // Get the hardcoded passcode to pass to the delete function
    // ⚠️ ERROR POINT 3: Accesses appState.staffPasscode. This required adding the 'get staffPasscode' getter to app_state.dart.
    final String staffPasscode = appState.staffPasscode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Lost & Found Feed'),
        actions: [
          // 🔑 Button to activate/deactivate staff mode
          TextButton(
            onPressed: appState.isStaffMode ? appState.deactivateStaffMode : _showStaffDialog,
            child: Text(
              appState.isStaffMode ? 'STAFF ACTIVE' : 'STAFF LOGIN',
              style: TextStyle(
                color: appState.isStaffMode ? Colors.red.shade700 : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          // ➕ Button to navigate to the Post Item Screen
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Implement navigation to Keziah's Post Item Screen here
              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PostItemScreen()));
            },
          ),
        ],
      ),

      body: supabaseService.items.isEmpty && supabaseService.items.isNotEmpty // This logic seems slightly confusing and may just be a typo: `supabaseService.items.isEmpty && supabaseService.items.isNotEmpty` is always false.
          ? const Center(child: CircularProgressIndicator()) // This line will never execute as written
          : supabaseService.items.isEmpty
          ? const Center(
        child: Text('No items posted yet. Be the first!'),
      )
          : ListView.builder(
        itemCount: supabaseService.items.length,
        itemBuilder: (context, index) {
          final item = supabaseService.items[index];

          return ListTile(
            leading: item.imageUrl.isNotEmpty
                ? Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.broken_image),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item.description),

            // 🗑️ Staff-Only Delete Button
            trailing: appState.isStaffMode
                ? IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () => _confirmAndDelete(context, item, staffPasscode),
            )
                : null,
            onTap: () {
              // TODO: Navigate to Item Detail Page
            },
          );
        },
      ),
    );
  }
}