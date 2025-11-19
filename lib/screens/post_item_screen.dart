import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked =
    await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a category')));
        return;
      }
      if (imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an image')));
        return;
      }

      _formKey.currentState!.save();

      // TODO: Submit to backend (Supabase)
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted! (Backend logic pending)')));

      Navigator.of(context).pop(); // Back to feed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Lost or Found Item'),
      ),
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
                validator: (val) =>
                val == null || val.isEmpty ? 'Title is required' : null,
                onSaved: (val) => title = val,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (val) =>
                val == null || val.isEmpty ? 'Description is required' : null,
                onSaved: (val) => description = val,
              ),
              const SizedBox(height: 12),

              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                value: category,
                onChanged: (val) => setState(() => category = val),
                validator: (val) =>
                val == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 12),

              // Status radio buttons
              Row(
                children: [
                  const Text('Status:'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Lost'),
                      value: 'lost',
                      groupValue: status,
                      onChanged: (val) => setState(() => status = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Found'),
                      value: 'found',
                      groupValue: status,
                      onChanged: (val) => setState(() => status = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Image picker
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ],
              ),
              if (imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.file(imageFile!, height: 150),
                ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
