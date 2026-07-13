import 'package:flutter/material.dart';
import '../model/Activity.dart';
import '../service/ActivityDBHelper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'ActivityDetailScreen.dart';
import 'ActivityFormScreen.dart';

class ActivityListScreen extends StatelessWidget {
  const ActivityListScreen({super.key});

  Future<bool> _confirmDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // void updateActivity(BuildContext context, String docId) {
  // }

  // void deleteActivity(BuildContext context, String docId) async {
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Activities'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ActivityFormScreen()),
          );
        },
        backgroundColor: Colors.blueGrey[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Activity>>(
        stream: ActivityDBHelper.getActivitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data not found'));
          }

          final actlist = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: actlist.length,
            itemBuilder: (context, index) {
              final act_item = actlist[index];

              return Slidable(
                // Specify a key if the Slidable is dismissible.
                key: ValueKey(act_item.id),

                // The start action pane is the one at the left or the top side.
                endActionPane: ActionPane(
                  // A motion is a widget used to control how the pane animates.
                  motion: const ScrollMotion(),

                  // A pane can dismiss the Slidable.
                  dismissible: DismissiblePane(onDismissed: () {}),

                  // All actions are defined in the children parameter.
                  children: [
                    // A SlidableAction can have an icon and/or a label.
                    SlidableAction(
                      onPressed: (context) async {
                        final ok = await _confirmDialog(
                          context,
                          'Delete Activity',
                          'Delete "${act_item.title}"?',
                        );
                        if (ok) {
                          ActivityDBHelper.deleteActivity(act_item.id);
                        }
                      },
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ActivityFormScreen(activity: act_item),
                          ),
                        );
                      },
                      backgroundColor: const Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                  ],
                ),

                child: Card(
                  // return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      act_item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      act_item.desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),

                    // onTap: () {
                    //   // TODO: Navigator.push to view participate
                    // },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ActivityDetailScreen(activity: act_item),
                        ),
                      );
                    }, //onTab
                  ),
                ),
              ); //card
            },
          );
        },
      ),
    );
  }
}
