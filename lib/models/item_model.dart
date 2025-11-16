class ItemModel {
  final String? id;
  final String type; // 'lost' or 'found'
  final String category; // 'Electronics', 'ID/Cards', etc.
  final String title;
  final String status;
  final String description;
  final String location; // Where item was lost/found
  final String dateLostFound; // Date: '2024-11-16'
  final String? imageUrl;
  final DateTime timeCreated;

  ItemModel({
    this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.status,
    required this.description,
    required this.location,
    required this.dateLostFound,
    this.imageUrl,
    DateTime? timeCreated,
  }) : timeCreated = timeCreated ?? DateTime.now();

  // Convert from Supabase JSON to Dart object
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      type: json['type'],
      category: json['category'],
      title: json['title'],
      status: json['status'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      dateLostFound: json['date_lost_found'] ?? '',
      imageUrl: json['image_url'],
      timeCreated: json['time_created'] != null
          ? DateTime.parse(json['time_created'])
          : DateTime.now(),
    );
  }

  // Convert from Dart object to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'category': category,
      'title': title,
      'status': status,
      'description': description,
      'location': location,
      'date_lost_found': dateLostFound,
      'image_url': imageUrl,
      // time_created and time_updated are auto-handled by Supabase
    };
  }
}