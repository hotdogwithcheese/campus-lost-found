// Path: lib/services/supabase_service.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item_model.dart';

// Assuming Supabase is initialized in main.dart, we can access the client globally.
final SupabaseClient supabase = Supabase.instance.client;

class SupabaseService extends ChangeNotifier {
  // 1. Data Store: The list of items fetched from the database.
  // This must be a List<ItemModel> to match the usage in home_screen.dart
  List<ItemModel> _items = [];

  // 🔑 Getter: Required by home_screen.dart (Provider.of<SupabaseService>().items)
  List<ItemModel> get items => _items;

  // --- Core CRUD Methods ---

  // 🎯 Method 1: Fetch all lost/found items
  // Required by home_screen.dart (to display the list).
  Future<void> fetchItems() async {
    // Rexie's TODO: Replace this placeholder logic with actual Supabase select query.
    print('Service: Attempting to fetch items...');

    try {
      // ⚠️ IMPORTANT: Verify 'items_table' is the correct name of your Supabase table!
      final response = await supabase
          .from('items_table')
          .select()
          .order('id', ascending: false);

      // Map the raw JSON response into Dart objects (ItemModel).
      final List<ItemModel> fetchedItems =
      (response as List).map((itemJson) => ItemModel.fromJson(itemJson)).toList();

      // Update the state and notify the UI
      _items = fetchedItems;
      notifyListeners();

    } catch (e) {
      // Print the error to the console. This helps debug the Red Screen.
      print('SUPABASE FETCH FAILED: $e');
      // Keep the local list empty if the fetch fails
      _items = [];
      notifyListeners();
    }
  }


  // 🎯 Method 2: Staff-only deletion
  // Required by home_screen.dart (for the delete button logic).
  Future<bool> staffDeleteItem(int id, String passcode) async {
    // Rexie's TODO: Replace this placeholder with the secure Supabase RPC call.
    print('Service: Attempting to delete item $id with passcode: $passcode');

    try {
      // We assume a secure Supabase Function (RPC) handles the passcode check and delete.
      final response = await supabase.rpc(
        'staff_action', // ⚠️ IMPORTANT: Verify this Supabase function name exists!
        params: {
          'item_id_to_delete': id,
          'passcode_input': passcode,
        },
      );

      // Assuming the RPC returns some indication of success (e.g., non-null result)
      if (response != null) {
        // Update local state immediately upon success
        _items.removeWhere((item) => item.id == id);
        notifyListeners();
        return true;
      }
      return false;

    } catch (error) {
      print('SUPABASE DELETE FAILED: $error');
      return false; // Deletion failed
    }
  }

}