import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_theme.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Timetable'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Add new class
              },
            ),
          ],
        ),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024),
              lastDay: DateTime.utc(2024, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                formatButtonTextStyle: const TextStyle(color: Colors.white),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: _buildClassList(),
            ),
          ],
        ),
      );

  Widget _buildClassList() {
    // Mock classes for the selected day
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
      return const Center(
        child: Text('No classes scheduled for this day'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classData = classes[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            leading: Container(
              width: 4.w,
              height: 50.h,
              color: classData['color']! as Color,
            ),
            title: Text(classData['course']! as String),
            subtitle: Text('${classData['code']} • ${classData['room']}'),
            trailing: Text(classData['time']! as String),
          ),
        );
      },
    );
  }
}
