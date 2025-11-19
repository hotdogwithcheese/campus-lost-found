import 'package:flutter/material.dart';

class StaffAccessScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const StaffAccessScreen({super.key, required this.items});

  @override
  State<StaffAccessScreen> createState() => _StaffAccessScreenState();
}

class _StaffAccessScreenState extends State<StaffAccessScreen> {
  final TextEditingController _pinController = TextEditingController();
  final String staffPin = "1234"; // placeholder PIN
  bool isStaff = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Access')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isStaff
            ? ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(item['title']),
                subtitle: Text("${item['category']} • ${item['status']}"),
                trailing: item['isClaimed'] == true
                    ? const Chip(
                  label: Text("Claimed"),
                  backgroundColor: Colors.greenAccent,
                )
                    : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      item['isClaimed'] = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item marked as claimed')));
                  },
                  child: const Text('Mark as Claimed'),
                ),
              ),
            );
          },
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'Enter Staff PIN',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_pinController.text == staffPin) {
                  setState(() => isStaff = true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect PIN')));
                }
              },
              child: const Text('Activate Staff Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
