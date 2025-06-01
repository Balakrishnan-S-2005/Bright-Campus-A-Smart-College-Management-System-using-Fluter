import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminCalendarScreen extends StatefulWidget {
  @override
  _AdminCalendarScreenState createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};
  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() {
    FirebaseFirestore.instance.collection('events').get().then((snapshot) {
      Map<DateTime, List<String>> tempEvents = {};

      for (var doc in snapshot.docs) {
        DateTime eventDate = (doc['date'] as Timestamp).toDate();
        String eventTitle = doc['title'];
        DateTime eventKey = DateTime(eventDate.year, eventDate.month, eventDate.day);

        if (tempEvents.containsKey(eventKey)) {
          tempEvents[eventKey]!.add(eventTitle);
        } else {
          tempEvents[eventKey] = [eventTitle];
        }
      }

      setState(() {
        _events = tempEvents;
      });
    });
  }

  void _addEvent() {
    if (_eventController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('events').add({
        'title': _eventController.text,
        'date': Timestamp.fromDate(_selectedDay), // Save only for selected day
      });

      _eventController.clear();
      Navigator.pop(context);
      _fetchEvents();
    }
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Event for ${_selectedDay.toLocal()}"),
          content: TextField(
            controller: _eventController,
            decoration: InputDecoration(labelText: "Event Title"),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Add"),
              onPressed: _addEvent,
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(String id) {
    FirebaseFirestore.instance.collection('events').doc(id).delete();
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Calendar",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _events[DateTime(day.year, day.month, day.day)] ?? [];
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)))
                  .where('date', isLessThan: Timestamp.fromDate(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day + 1))) // Show only selected day's events
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var events = snapshot.data!.docs;

                return events.isNotEmpty
                    ? ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    var event = events[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(event['title']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEvent(event.id),
                        ),
                      ),
                    );
                  },
                )
                    : Center(child: Text("No events on this day", style: TextStyle(fontSize: 18)));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}