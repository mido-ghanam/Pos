// products_screen.dart
import 'package:flutter/material.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المخزن')),
      body: const Center(child: Text('شاشة المخزن - قريباً', style: TextStyle(fontSize: 20))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add),
      ),
    );
  }
}
