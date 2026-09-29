
import 'package:flutter/material.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  String _travelStyle = 'Balanced';

  @override
  void dispose() {
    _placeController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _generateItinerary() {
    final place = _placeController.text.trim();
    final days = int.tryParse(_daysController.text.trim());

    if (place.isEmpty || days == null || days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a destination and valid number of days.',
          ),
        ),
      );
      return;
    }

    // AI integration will be added here later.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Itinerary generation will be connected to AI next.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'AI Itinerary',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // HEADER
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE1E1E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 35,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create Your Itinerary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Enter your destination and number of days. '
                    'AI will create a detailed travel plan for you.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // =========================
            // DESTINATION
            // =========================
            const Text(
              'Where do you want to go?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                hintText: 'e.g. Goa, Manali, Jaipur',
                prefixIcon: const Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // NUMBER OF DAYS
            // =========================
            const Text(
              'How many days?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 3',
                prefixIcon: const Icon(Icons.calendar_month_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // TRAVEL STYLE
            // =========================
            const Text(
              'Travel Style',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _travelStyle,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'Budget',
                      child: Text('Budget'),
                    ),
                    DropdownMenuItem(
                      value: 'Balanced',
                      child: Text('Balanced'),
                    ),
                    DropdownMenuItem(
                      value: 'Luxury',
                      child: Text('Luxury'),
                    ),
                    DropdownMenuItem(
                      value: 'Adventure',
                      child: Text('Adventure'),
                    ),
                    DropdownMenuItem(
                      value: 'Relaxed',
                      child: Text('Relaxed'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _travelStyle = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // GENERATE BUTTON
            // =========================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _generateItinerary,
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  'Generate Itinerary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // WHAT AI WILL GENERATE
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE1E1E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your AI itinerary will include:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),

                  _FeatureRow(
                    icon: Icons.calendar_today_outlined,
                    text: 'Day-by-day travel plan',
                  ),

                  _FeatureRow(
                    icon: Icons.wb_sunny_outlined,
                    text: 'Morning, afternoon and evening activities',
                  ),

                  _FeatureRow(
                    icon: Icons.place_outlined,
                    text: 'Recommended places to visit',
                  ),

                  _FeatureRow(
                    icon: Icons.restaurant_outlined,
                    text: 'Food and restaurant suggestions',
                  ),

                  _FeatureRow(
                    icon: Icons.access_time_outlined,
                    text: 'Suggested timings for activities',
                  ),

                  _FeatureRow(
                    icon: Icons.directions_car_outlined,
                    text: 'Travel/route suggestions',
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

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

