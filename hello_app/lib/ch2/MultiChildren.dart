import 'package:flutter/material.dart';

class MultiChildrenExample extends StatelessWidget {
  const MultiChildrenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตัวอย่าง: children (หลายตัว)')),
      body: Column(
        //List
        children: const [
          Text('ลูกคนที่ 1: สวัสดีครับอาจารย์'),
          Text('ลูกคนที่ 2: สวัสดีครับเพื่อน ๆ'),
          Text('ลูกคนที่ 3: วันนี้เรียนสนุกมาก'),
        ],
      ),
    );
  }
}
