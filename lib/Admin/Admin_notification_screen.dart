import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationsScreen extends StatefulWidget {
  @override
  _AdminNotificationsScreenState createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void _addNotification() {
    if (_titleController.text.isNotEmpty && _messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text,
        'message': _messageController.text,
        'date': DateTime.now().toString(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _messageController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Notification"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(labelText: "Message"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Add"),
              onPressed: _addNotification,
            ),
          ],
        );
      },
    );
  }

  void _deleteNotification(String id) {
    FirebaseFirestore.instance.collection('notifications').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Notifications",style: TextStyle(color: Colors.white)),backgroundColor: Color(0xFF674AEF),),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('notifications').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(notification['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(notification['message']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNotification(notification.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNotificationDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}