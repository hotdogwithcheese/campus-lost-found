import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Your custom configuration and state files
import 'config/supabase_config.dart';
import 'services/supabase_service.dart';
import 'app_state.dart';

// Your milestone placeholder screen
import 'screens/home_screen.dart';

// -----------------------------------------------------------------------------
// Application Entry Point
// -----------------------------------------------------------------------------
Future<void> main() async {
  // 1. Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Supabase using the constants from your config file
  // NOTE: You MUST have filled in the keys in lib/config/supabase_config.dart
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // 3. Run the main app widget
  runApp(const App());
}

// -----------------------------------------------------------------------------
// State Management Wrapper (Provider)
// -----------------------------------------------------------------------------
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap the app with two Providers:
    // 1. AppState (for Staff Passcode logic)
    // 2. SupabaseService (for handling database interactions later)
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: ChangeNotifierProvider(
        create: (_) => SupabaseService(),
        child: const AppView(),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// App View (MaterialApp Setup)
// -----------------------------------------------------------------------------
class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Lost & Found App',
      theme: ThemeData(primarySwatch: Colors.blue),

      // CRITICAL FOR MILESTONE B:
      // This displays the HomeScreen placeholder you created.
      home: const HomeScreen(),
    );
  }
}