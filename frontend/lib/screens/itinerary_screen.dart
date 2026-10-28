// lib/screens/itinerary_screen.dart

import 'package:flutter/material.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final destinationController = TextEditingController();
  int days = 3;
  String style = 'Balanced';

  List<Map<String, dynamic>> itinerary = [];

  void _generateItinerary() {
    final destination = destinationController.text.trim();

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a destination first.'),
        ),
      );
      return;
    }

    final activities = [
      [
        'Arrival & Local Exploration',
        'Check in, explore the local market and nearby attractions.',
      ],
      [
        'Main Attractions',
        'Visit the most popular attractions and try local food.',
      ],
      [
        'Adventure & Relaxation',
        'Enjoy an outdoor activity followed by a relaxed evening.',
      ],
      [
        'Culture & Shopping',
        'Explore local culture, shopping areas and hidden spots.',
      ],
      [
        'Scenic Day',
        'Visit viewpoints and enjoy the surrounding landscape.',
      ],
      [
        'Free Exploration',
        'Keep the day flexible for places you discover along the way.',
      ],
      [
        'Departure',
        'Breakfast, final shopping and departure.',
      ],
    ];

    setState(() {
      itinerary = List.generate(days, (index) {
        final activity = activities[index % activities.length];

        return {
          'day': index + 1,
          'title': activity[0],
          'description': activity[1],
        };
      });
    });
  }

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                hintText: 'Destination',
                prefixIcon: const Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text(
                  'Days:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    if (days > 1) setState(() => days--);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$days'),
                IconButton(
                  onPressed: () {
                    if (days < 14) setState(() => days++);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: style,
                  items: [
                    'Budget',
                    'Balanced',
                    'Luxury',
                    'Adventure',
                    'Relaxed',
                  ]
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => style = value!);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _generateItinerary,
                child: const Text('Generate Itinerary'),
              ),
            ),
            const SizedBox(height: 25),
            if (itinerary.isNotEmpty)
              Text(
                '${destinationController.text.trim()} • $style',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 12),
            ...itinerary.map(
              (day) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      child: Text(day['day'].toString()),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day['title'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            day['description'].toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}