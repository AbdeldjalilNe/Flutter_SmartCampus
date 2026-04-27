import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/announcement_card.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock announcements data
    final announcements = [
      {
        'title': 'Midterm Exam Schedule Released',
        'content':
            'The midterm exam schedule for Fall 2024 has been released. Please check your student portal for details.',
        'author': 'Academic Office',
        'time': '2 hours ago',
        'isUrgent': true,
      },
      {
        'title': 'Library Hours Extended',
        'content':
            'The university library will now be open until midnight during exam weeks.',
        'author': 'Library Services',
        'time': '5 hours ago',
        'isUrgent': false,
      },
      {
        'title': 'New Cafeteria Menu',
        'content':
            'Check out the new healthy options available at the student cafeteria starting next week.',
        'author': 'Food Services',
        'time': '1 day ago',
        'isUrgent': false,
      },
      {
        'title': 'Campus WiFi Maintenance',
        'content':
            'There will be scheduled maintenance on the campus WiFi network this weekend.',
        'author': 'IT Services',
        'time': '2 days ago',
        'isUrgent': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: AnnouncementCard(
              title: announcement['title']! as String,
              content: announcement['content']! as String,
              author: announcement['author']! as String,
              time: announcement['time']! as String,
              isUrgent: announcement['isUrgent']! as bool,
              onTap: () {
                // Navigate to announcement detail
              },
            ),
          );
        },
      ),
    );
  }
}
