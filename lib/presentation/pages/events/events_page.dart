import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/event_card.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock events data
    final events = [
      {
        'title': 'Career Fair 2024',
        'date': 'Tomorrow',
        'time': '10:00 AM - 4:00 PM',
        'location': 'Student Center',
        'attendees': 150,
      },
      {
        'title': 'Tech Talk: AI in Education',
        'date': 'Fri, Dec 15',
        'time': '2:00 PM - 4:00 PM',
        'location': 'Auditorium A',
        'attendees': 80,
      },
      {
        'title': 'Winter Concert',
        'date': 'Sat, Dec 16',
        'time': '7:00 PM - 9:00 PM',
        'location': 'Main Hall',
        'attendees': 200,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Show calendar view
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: EventCard(
              title: event['title']! as String,
              date: event['date']! as String,
              time: event['time']! as String,
              location: event['location']! as String,
              attendees: event['attendees']! as int,
              onTap: () {
                // Navigate to event detail
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new event (admin only)
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
