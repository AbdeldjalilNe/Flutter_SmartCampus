import 'package:flutter/material.dart';

class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({
    super.key,
    required this.announcementId,
  });
  final String announcementId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Announcement'),
        ),
        body: const Center(
          child: Text('Announcement Detail Page'),
        ),
      );
}
