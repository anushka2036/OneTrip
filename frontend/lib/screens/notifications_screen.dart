
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [

          // =========================
          // UPCOMING TRIP
          // =========================
          _notificationCard(
            icon: Icons.flight_takeoff_outlined,
            title: 'Upcoming Trip',
            message: 'Your Manali trip is coming up on 12 October.',
            time: 'Today',
            onTap: () {},
          ),

          // =========================
          // ITINERARY
          // =========================
          _notificationCard(
            icon: Icons.event_note_outlined,
            title: 'Itinerary Ready',
            message: 'Your AI-generated itinerary is ready to view.',
            time: '2 hours ago',
            onTap: () {},
          ),

          // =========================
          // EXPENSE
          // =========================
          _notificationCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Budget Reminder',
            message: 'You have used 70% of your trip budget.',
            time: 'Yesterday',
            onTap: () {},
          ),

          // =========================
          // TICKET
          // =========================
          _notificationCard(
            icon: Icons.receipt_long_outlined,
            title: 'Ticket Processed',
            message: 'Your uploaded ticket details have been extracted.',
            time: '2 days ago',
            onTap: () {},
          ),

          // =========================
          // TRAVEL TIP
          // =========================
          _notificationCard(
            icon: Icons.lightbulb_outline,
            title: 'Travel Tip',
            message: 'Check your itinerary before starting your trip.',
            time: '3 days ago',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _notificationCard({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE1E1E1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ICON
            Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.black87,
                size: 23,
              ),
            ),

            const SizedBox(width: 12),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

