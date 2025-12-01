import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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

  // Image variables
  File? imageFile;          // Mobile
  Uint8List? imageBytes;    // Web
  String? imageFileName;    // File name

  final List<String> categories = [
    'Electronics',
    'Bags',
    'Books',
    'Clothing',
    'Accessories',
    'Others',
  ];

  final ImagePicker _picker = ImagePicker();

  /// Pick image for mobile or web
  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null) {
        setState(() {
          imageBytes = result.files.first.bytes;
          imageFileName = result.files.first.name;
        });
      }
    } else {
      // Mobile gallery
      final XFile? picked =
      await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
      if (picked != null) {
        setState(() {
          imageFile = File(picked.path);
          imageFileName = picked.name;
        });
      }
    }
  }

  /// Mobile-only camera picker
  Future<void> _pickImageFromCamera() async {
    if (!kIsWeb) {
      final XFile? picked =
      await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
      if (picked != null) {
        setState(() {
          imageFile = File(picked.path);
          imageFileName = picked.name;
        });
      }
    }
  }

  /// Upload image to Supabase
  Future<String?> _uploadImage() async {
    try {
      final bucket = SupabaseConfig.client.storage.from('item-images');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFileName!}';

      if (kIsWeb) {
        // Web upload
        await bucket.uploadBinary(fileName, imageBytes!);
      } else {
        // Mobile upload
        await bucket.upload(fileName, imageFile!);
      }

      // ✅ Fix: getPublicUrl returns a string directly
      return bucket.getPublicUrl(fileName);
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  /// Save item to Supabase DB
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

  /// Submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    if (imageFile == null && imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    _formKey.currentState!.save();
    final imageUrl = await _uploadImage();
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
    final radioTheme = Theme.of(context).copyWith(
      radioTheme: RadioThemeData(
        fillColor: MaterialStateColor.resolveWith((states) => Colors.blue),
      ),
    );

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
                validator: (v) => v == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 12),

              // Status
              Row(
                children: [
                  const Text('Status:  '),
                  Expanded(
                    child: Theme(
                      data: radioTheme,
                      child: RadioListTile(
                        title: const Text('Lost'),
                        value: 'lost',
                        groupValue: status,
                        onChanged: (v) => setState(() => status = v!),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Theme(
                      data: radioTheme,
                      child: RadioListTile(
                        title: const Text('Found'),
                        value: 'found',
                        groupValue: status,
                        onChanged: (v) => setState(() => status = v!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Image picker buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  // Only show camera button on mobile
                  if (!kIsWeb) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImageFromCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Image preview
              if (imageFile != null || imageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.memory(imageBytes!, height: 160, fit: BoxFit.cover)
                        : Image.file(imageFile!, height: 160, fit: BoxFit.cover),
                  ),
                ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
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
