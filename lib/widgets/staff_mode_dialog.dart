// Path: lib/widgets/staff_mode_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class StaffModeDialog extends StatefulWidget {
  const StaffModeDialog({super.key});

  @override
  State<StaffModeDialog> createState() => _StaffModeDialogState();
}

class _StaffModeDialogState extends State<StaffModeDialog> {
  final TextEditingController _passcodeController = TextEditingController();
  String _errorMessage = '';

  void _submitPasscode(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final code = _passcodeController.text.trim();

    // Check the passcode using the AppState logic
    if (appState.activateStaffMode(code)) {
      // Success: Close the dialog
      Navigator.of(context).pop();
    } else {
      // Failure: Show error message
      setState(() {
        _errorMessage = 'Invalid Passcode. Access Denied.';
      });
      _passcodeController.clear();
    }
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Staff Passcode Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Enter the secret staff passcode to unlock administrative features (Delete, Update).',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passcodeController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Passcode',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              onSubmitted: (_) => _submitPasscode(context),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: () => _submitPasscode(context),
          child: const Text('Login'),
        ),
      ],
    );
  }
}