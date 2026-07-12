import 'package:flutter/material.dart';
import '../model/Activity.dart';
import '../service/ActivityDBHelper.dart';

class ActivityFormScreen extends StatefulWidget {
  final Activity? activity;

  const ActivityFormScreen({super.key, this.activity});

  @override
  _ActivityFormScreenState createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _stdListController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity?.title ?? '');
    _descController = TextEditingController(text: widget.activity?.desc ?? '');
    _stdListController = TextEditingController(text: widget.activity?.stdList.join(", ") ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _stdListController.dispose();
    super.dispose();
  }

  void _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      List<String> stdList = _stdListController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      Map<String, dynamic> data = {
        'title': _titleController.text,
        'desc': _descController.text,
        'stdlist': stdList,
        // Keep existing dateFrom if updating, otherwise set a new date or let Firebase handle it
        'datefrom': widget.activity?.dateFrom ?? DateTime.now(), 
      };

      if (widget.activity == null) {
        await ActivityDBHelper.addActivity(data);
      } else {
        await ActivityDBHelper.updateActivity(widget.activity!.id, data);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? 'Add Activity' : 'Edit Activity'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _stdListController,
                decoration: const InputDecoration(labelText: 'Students (comma separated)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveActivity,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
