import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({
    super.key,
    required this.eventId,
  });
  final String eventId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Event Details'),
        ),
        body: const Center(
          child: Text('Event Detail Page'),
        ),
      );
}
