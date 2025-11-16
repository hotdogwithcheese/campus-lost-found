// Path: lib/services/supabase_service.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item_model.dart';

final SupabaseClient supabase = Supabase.instance.client;

class SupabaseService extends ChangeNotifier {
  List<ItemModel> _items = [];
  bool _isLoading = false;

  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading;

  // READ - Fetch all items
  Future<void> fetchItems() async {
    print('Service: Fetching items...');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase
          .from('items')
          .select()
          .order('time_created', ascending: false);

      _items = (response as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();

      print('Service: Fetched ${_items.length} items');

    } catch (e) {
      print('FETCH ERROR: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE - Post new item
  Future<bool> postItem(ItemModel item) async {
    try {
      await supabase.from('items').insert(item.toJson());
      await fetchItems(); // Refresh list
      print('Item posted successfully');
      return true;
    } catch (e) {
      print('POST ERROR: $e');
      return false;
    }
  }

  // DELETE - Staff only with password
  Future<bool> staffDeleteItem(String itemId, String passcode) async {
    print('Service: Delete attempt for item $itemId');

    // Simple password check (change '1234' to your staff password)
    if (passcode != '1234') {
      print('Invalid passcode');
      return false;
    }

    try {
      await supabase.from('items').delete().eq('id', itemId);

      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();

      print('Item deleted successfully');
      return true;

    } catch (error) {
      print('DELETE ERROR: $error');
      return false;
    }
  }

  // Filter by type (lost or found)
  List<ItemModel> getItemsByType(String type) {
    if (type == 'all') return _items;
    return _items.where((item) => item.type == type).toList();
  }
}