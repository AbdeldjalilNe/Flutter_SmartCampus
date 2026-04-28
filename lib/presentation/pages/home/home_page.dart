import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/event_card.dart';
import '../../widgets/timetable_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('SmartCampus'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Navigate to notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => context.push('/qr-scanner'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context),
              SizedBox(height: 24.h),

              // Quick Actions
              _buildQuickActions(context),
              SizedBox(height: 24.h),

              // Today's Classes
              _buildSectionHeader(
                context,
                title: "Today's Classes",
                onSeeAll: () => context.go('/timetable'),
              ),
              SizedBox(height: 12.h),
              _buildTodayClasses(),
              SizedBox(height: 24.h),

              // Latest Announcements
              _buildSectionHeader(
                context,
                title: 'Latest Announcements',
                onSeeAll: () => context.go('/announcements'),
              ),
              SizedBox(height: 12.h),
              _buildLatestAnnouncements(),
              SizedBox(height: 24.h),

              // Upcoming Events
              _buildSectionHeader(
                context,
                title: 'Upcoming Events',
                onSeeAll: () => context.go('/events'),
              ),
              SizedBox(height: 12.h),
              _buildUpcomingEvents(),
            ],
          ),
        ),
      );

  Widget _buildWelcomeSection(BuildContext context) =>
      BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          var userName = 'Student';
          if (state is Authenticated) {
            userName = state.user.firstName;
          }

          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: CircleAvatar(
                        radius: 30.w,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          size: 30.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16.w,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _getCurrentDate(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.map,
        label: 'Campus Map',
        color: AppTheme.secondaryColor,
        onTap: () => context.go('/map'),
      ),
      _QuickAction(
        icon: Icons.campaign,
        label: 'Announcements',
        color: AppTheme.accentColor,
        onTap: () => context.go('/announcements'),
      ),
      _QuickAction(
        icon: Icons.event,
        label: 'Events',
        color: AppTheme.infoColor,
        onTap: () => context.go('/events'),
      ),
      _QuickAction(
        icon: Icons.safety_check,
        label: 'Safety',
        color: AppTheme.warningColor,
        onTap: () => context.push('/safety'),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map(_buildQuickActionItem).toList(),
    );
  }

  Widget _buildQuickActionItem(_QuickAction action) => GestureDetector(
        onTap: action.onTap,
        child: Column(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: 28.w,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkColor,
              ),
            ),
          ],
        ),
      );

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onSeeAll,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkColor,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'See All',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      );

  Widget _buildTodayClasses() {
    // Mock data for today's classes
    final classes = [
      {
        'course': 'Mobile App Development',
        'code': 'CS401',
        'time': '09:00 - 11:00',
        'room': 'Lab 3',
        'color': AppTheme.primaryColor,
      },
      {
        'course': 'Database Systems',
        'code': 'CS305',
        'time': '13:00 - 15:00',
        'room': 'Room 201',
        'color': AppTheme.secondaryColor,
      },
    ];

    if (classes.isEmpty) {
      return _buildEmptyState('No classes today');
    }

    return Column(
      children: classes
          .map((classData) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: TimetableCard(
                  course: classData['course']! as String,
                  code: classData['code']! as String,
                  time: classData['time']! as String,
                  room: classData['room']! as String,
                  color: classData['color']! as Color,
                ),
              ),)
          .toList(),
    );
  }

  Widget _buildLatestAnnouncements() {
    // Mock data for announcements
    final announcements = [
      {
        'title': 'Midterm Exam Schedule Released',
        'content':
            'The midterm exam schedule for Fall 2024 has been released. Please check your student portal.',
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
    ];

    if (announcements.isEmpty) {
      return _buildEmptyState('No new announcements');
    }

    return Column(
      children: announcements
          .map((announcement) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: AnnouncementCard(
                  title: announcement['title']! as String,
                  content: announcement['content']! as String,
                  author: announcement['author']! as String,
                  time: announcement['time']! as String,
                  isUrgent: announcement['isUrgent']! as bool,
                ),
              ),)
          .toList(),
    );
  }

  Widget _buildUpcomingEvents() {
    // Mock data for events
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
    ];

    if (events.isEmpty) {
      return _buildEmptyState('No upcoming events');
    }

    return Column(
      children: events
          .map((event) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: EventCard(
                  title: event['title']! as String,
                  date: event['date']! as String,
                  time: event['time']! as String,
                  location: event['location']! as String,
                  attendees: event['attendees']! as int,
                ),
              ),)
          .toList(),
    );
  }

  Widget _buildEmptyState(String message) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppTheme.lightColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.mediumColor,
            ),
          ),
        ),
      );

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

class _QuickAction {
  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}
