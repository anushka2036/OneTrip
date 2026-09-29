import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedTheme = 'System Default';
  String travelStyle = 'Balanced';
  String language = 'English';

  bool notificationsEnabled = true;
  bool locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(selectedTheme),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showThemeOptions,
          ),

          const SizedBox(height: 20),

          const Text(
            'Travel Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.travel_explore),
            title: const Text('Travel Style'),
            subtitle: Text(travelStyle),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showTravelStyleOptions,
          ),

          const SizedBox(height: 20),

          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Receive trip and reminder notifications'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.location_on_outlined),
            title: const Text('Location Services'),
            subtitle: const Text('Allow location-based travel features'),
            value: locationEnabled,
            onChanged: (value) {
              setState(() {
                locationEnabled = value;
              });
            },
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(language),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguageOptions,
          ),

          const SizedBox(height: 20),

          const Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Account & Privacy'),
            subtitle: const Text('Manage your account and privacy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account settings will be connected later.'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help with OneTrip'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & Support will be added later.'),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _logout,
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              'OneTrip\nSmart Travel Companion',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Select Theme',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _optionTile(
              'System Default',
              selectedTheme,
              (value) {
                setState(() {
                  selectedTheme = value;
                });
                Navigator.pop(context);
              },
            ),
            _optionTile(
              'Light',
              selectedTheme,
              (value) {
                setState(() {
                  selectedTheme = value;
                });
                Navigator.pop(context);
              },
            ),
            _optionTile(
              'Dark',
              selectedTheme,
              (value) {
                setState(() {
                  selectedTheme = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showTravelStyleOptions() {
    final styles = [
      'Budget',
      'Balanced',
      'Luxury',
      'Adventure',
      'Relaxed',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Travel Style',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...styles.map(
              (style) => _optionTile(
                style,
                travelStyle,
                (value) {
                  setState(() {
                    travelStyle = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageOptions() {
    final languages = [
      'English',
      'Hindi',
      'Marathi',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Language',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...languages.map(
              (lang) => _optionTile(
                lang,
                language,
                (value) {
                  setState(() {
                    language = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _optionTile(
    String value,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return ListTile(
      title: Text(value),
      trailing: value == selectedValue
          ? const Icon(Icons.check)
          : null,
      onTap: () => onSelected(value),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Logout will be connected to Firebase Auth later.',
                    ),
                  ),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}