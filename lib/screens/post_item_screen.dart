import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? description;
  String? category;
  String status = 'lost';
  File? imageFile;

  final List<String> categories = [
    'Electronics',
    'Bags',
    'Books',
    'Clothing',
    'Accessories',
    'Others',
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked =
    await _picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final bucket = SupabaseConfig.client.storage.from('item-images');
      await bucket.upload(fileName, image,
          fileOptions: const FileOptions(upsert: false, cacheControl: '3600'));
      return bucket.getPublicUrl(fileName);
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  Future<void> _saveItem(String imageUrl) async {
    await SupabaseConfig.client.from(SupabaseConfig.itemsTableName).insert({
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'image_url': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    _formKey.currentState!.save();
    final imageUrl = await _uploadImage(imageFile!);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed')),
      );
      return;
    }

    await _saveItem(imageUrl);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item posted successfully')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Lost or Found Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Title is required' : null,
                onSaved: (v) => title = v,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) =>
                v == null || v.isEmpty ? 'Description is required' : null,
                onSaved: (v) => description = v,
              ),
              const SizedBox(height: 12),

              // Category
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => category = v),
                validator: (v) =>
                v == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 12),

              // Status
              Row(
                children: [
                  const Text('Status:  '),
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Lost'),
                      value: 'lost',
                      groupValue: status,
                      onChanged: (v) => setState(() => status = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Found'),
                      value: 'found',
                      groupValue: status,
                      onChanged: (v) => setState(() => status = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Image picker row (uniform buttons)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),

              // Preview
              if (imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(imageFile!, height: 160, fit: BoxFit.cover),
                  ),
                ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor, // theme color
                    foregroundColor: Colors.white, // text color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
