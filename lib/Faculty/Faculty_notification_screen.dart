import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF)),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('notifications').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return Center(child: Text("No notifications available", style: TextStyle(fontSize: 18)));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(notification['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(notification['message']),
                  trailing: Text(notification['date']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}