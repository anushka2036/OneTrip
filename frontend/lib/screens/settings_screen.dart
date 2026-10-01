// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool locationServices = true;
  String travelStyle = 'Balanced';
  String language = 'English';
  String theme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _dropdown(
            icon: Icons.palette_outlined,
            title: 'Theme',
            value: theme,
            values: ['System', 'Light', 'Dark'],
            onChanged: (value) {
              setState(() => theme = value!);
            },
          ),
          _dropdown(
            icon: Icons.flight_takeoff_outlined,
            title: 'Travel Style',
            value: travelStyle,
            values: [
              'Budget',
              'Balanced',
              'Luxury',
              'Adventure',
              'Relaxed',
            ],
            onChanged: (value) {
              setState(() => travelStyle = value!);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            value: notifications,
            onChanged: (value) {
              setState(() => notifications = value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.location_on_outlined),
            title: const Text('Location Services'),
            value: locationServices,
            onChanged: (value) {
              setState(() => locationServices = value);
            },
          ),
          _dropdown(
            icon: Icons.language_outlined,
            title: 'Language',
            value: language,
            values: ['English', 'Hindi', 'Marathi'],
            onChanged: (value) {
              setState(() => language = value!);
            },
          ),
          const SizedBox(height: 25),
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _item(
            Icons.person_outline,
            'Account & Privacy',
            () {},
          ),
          _item(
            Icons.help_outline,
            'Help & Support',
            () {},
          ),
          _item(
            Icons.info_outline,
            'About OneTrip',
            () {},
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required IconData icon,
    required String title,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: values
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}