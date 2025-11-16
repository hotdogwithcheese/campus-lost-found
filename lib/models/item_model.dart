// Path: lib/models/item_model.dart

class ItemModel {

  final int? id;
  final String title;
  final String description;
  final String imageUrl;

  // Constructor
  ItemModel({
    this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  // 2. Factory Constructor for JSON Deserialization
  // This converts the Map<String, dynamic> (JSON row from Supabase) into an ItemModel object.
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    // ⚠️ CRITICAL: The string keys (e.g., 'title', 'image_url') MUST exactly match
    // the column names in your Supabase table.
    return ItemModel(
      // Ensure 'id' is mapped to your primary key column. It's nullable for new inserts.
      id: json['id'] as int?,

      // Ensure 'title' matches the column storing the item's main name.
      // If the column in Supabase is named 'item_name', you must use json['item_name'].
      title: json['title'] as String,

      // Ensure 'description' matches the corresponding column.
      description: json['description'] as String,

      // Ensure 'imageUrl' matches the corresponding column.
      imageUrl: json['image_url'] as String,
    );
  }

  // Optional: A method to convert the object back to JSON for sending data back to Supabase (e.g., when posting a new item)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
    };
  }
}