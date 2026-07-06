import 'package:flutter/material.dart';
import '../model/Activity.dart';
import '../service/ActivityDBHelper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';  

class ActivityListScreen extends StatelessWidget {
  const ActivityListScreen({super.key});

  // void updateActivity(BuildContext context, String docId) {
  // }

  // void deleteActivity(BuildContext context, String docId) async {
  // }

  void _deleteActivity(BuildContext context, String docId) {
    ActivityDBHelper.deleteActivity(docId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleting ...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Activities'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
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

              //** */

              return Slidable(		//1. return

                key: const ValueKey(0),

                endActionPane: ActionPane(
                  motion: const ScrollMotion(),

                  // A pane can dismiss the Slidable.
                  dismissible: DismissiblePane(onDismissed: () {}),

                  children: [		//2. ตัด const ออก

                    SlidableAction(
                      onPressed: (context) {},	//3.1 ไม่ต้องระบุการกด
					//onPressed: (context) => _deleteActivity(context, act_item.id),
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (context) {}, //3.2 ไม่ต้องระบุการกด
                      backgroundColor: Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.share,
                      label: 'Share',
                    ),
                  ],
                ),

                child: Card(   // 4. เปลี่ยนจาก return เป็น child: Card ไม่ต้องมี const
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
                          builder: (context) => const Placeholder(),
                          // ActivityDetailScreen(
                          //   title: act_item.title,
                          //   stdList: act_item.stdList,
                          // ),
                        ),
                      );
                    }, //onTab
                  ), //listTile
                ),//CaRD
              );//	5. เติมวงเล็บล Slidable
            },
          );
        },
      ),
    );
  }
}
