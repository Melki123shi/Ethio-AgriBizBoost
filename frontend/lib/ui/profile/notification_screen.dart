import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationScreen> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: pushNotifications,
            onChanged: (val) => setState(() => pushNotifications = val),
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            value: emailNotifications,
            onChanged: (val) => setState(() => emailNotifications = val),
          ),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            value: smsNotifications,
            onChanged: (val) => setState(() => smsNotifications = val),
          ),
        ],
      ),
    );
  }
}
