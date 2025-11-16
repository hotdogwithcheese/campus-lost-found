// Path: lib/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';
// Use an abstract class purely to hold static constants
abstract class SupabaseConfig {

  static const String supabaseUrl = 'https://sdozzwwrqtvsaoxpnbgh.supabase.co';

  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkb3p6d3dycXR2c2FveHBuYmdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwNDMxOTksImV4cCI6MjA3ODYxOTE5OX0.24p5MYn4kXlYjPCtbq8nJa2sWofVilBa5wzrR4pIWBE';

  static const String itemsTableName = 'items';

  static Future<void> initialize() async {
  await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
  );
  }

  // Getter to access the Supabase client
  static SupabaseClient get client {
  return Supabase.instance.client;
  }
  }
