import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<_NotificationItem> notifications = [
    _NotificationItem(title: "Welcome to the app!", viewed: true),
    _NotificationItem(title: "Your profile has been updated", viewed: false),
    _NotificationItem(
        title: "New crop recommendations available", viewed: false),
    _NotificationItem(title: "Password changed successfully", viewed: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            tileColor: notification.viewed
                ? const Color.fromARGB(255, 58, 98, 61)
                : const Color.fromARGB(255, 92, 114, 94),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            title: Text(
              notification.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    notification.viewed ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            trailing: Icon(
              notification.viewed ? Icons.done : Icons.fiber_manual_record,
              size: 18,
              color:
                  notification.viewed ? Colors.grey : const Color(0xFF94C495),
            ),
            onTap: () {
              setState(() {
                notifications[index].viewed = true;
              });
            },
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  bool viewed;

  _NotificationItem({required this.title, this.viewed = false});
}
