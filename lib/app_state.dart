// Path: lib/app_state.dart

import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // 🔑 The hardcoded secret passcode. This must match the code in the
  // 'staff_action' function in Supabase (which is also set to '1234').
  final String _staffPasscode = '1234';

  // 🎯 ADD THIS: Public getter for the passcode needed by HomeScreen
  String get staffPasscode => _staffPasscode;

  // 🔒 The main state variable: Is the user in staff mode?
  bool _isStaffMode = false;

  // Getter to allow widgets to read the current state
  bool get isStaffMode => _isStaffMode;

  // -------------------------------------------------------------------------
  // Logic to activate staff mode
  // -------------------------------------------------------------------------
  bool activateStaffMode(String code) {
    if (code == _staffPasscode) {
      _isStaffMode = true;
      // Tells all listening widgets (like the HomeScreen) to rebuild
      notifyListeners();
      return true; // Activation success
    }
    return false; // Activation failed
  }

  // Logic to deactivate staff mode
  void deactivateStaffMode() {
    _isStaffMode = false;
    notifyListeners();
  }
}