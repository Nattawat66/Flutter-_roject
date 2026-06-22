import 'package:flutter/material.dart';

class RowPageOverflow extends StatelessWidget {
  const RowPageOverflow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3. Row Layout (Before: overflow)'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            // error, overflow here
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 60,
                color: Colors.orange,
                child: const Center(child: Text('box A')),
              ),
              Container(
                width: 90,
                height: 60,
                color: Colors.purple,
                child: const Center(child: Text('box B')),
              ),
              Container(
                width: 90,
                height: 60,
                color: Colors.teal,
                child: const Center(child: Text('box C')),
              ),
              Container(
                width: 90,
                height: 60,
                color: Colors.blue,
                child: const Center(child: Text('box D')),
              ),
              Container(
                width: 90,
                height: 60,
                color: Colors.pink,
                child: const Center(child: Text('box E')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
