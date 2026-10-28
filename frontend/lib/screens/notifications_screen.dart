// lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'icon': Icons.luggage_outlined,
        'title': 'Upcoming Trip',
        'message': 'Your Manali trip is coming up on 12 October.',
        'time': '2 hours ago',
      },
      {
        'icon': Icons.event_note_outlined,
        'title': 'Itinerary Ready',
        'message': 'Your itinerary has been prepared.',
        'time': '5 hours ago',
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'title': 'Budget Reminder',
        'message': 'You have ₹6,500 remaining in your trip budget.',
        'time': 'Yesterday',
      },
      {
        'icon': Icons.receipt_long_outlined,
        'title': 'Ticket Processed',
        'message': 'Your travel ticket has been added successfully.',
        'time': 'Yesterday',
      },
      {
        'icon': Icons.lightbulb_outline,
        'title': 'Travel Tip',
        'message': 'Keep digital copies of your important documents.',
        'time': '2 days ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(item['icon'] as IconData),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['message'].toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['time'].toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}