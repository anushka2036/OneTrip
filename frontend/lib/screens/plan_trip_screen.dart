// lib/screens/plan_trip_screen.dart

import 'package:flutter/material.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final destinationController = TextEditingController();
  final budgetController = TextEditingController();

  int days = 3;
  String travelStyle = 'Balanced';
  DateTime? startDate;

  @override
  void dispose() {
    destinationController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        startDate = date;
      });
    }
  }

  void _createTrip() {
    final destination = destinationController.text.trim();

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a destination.'),
        ),
      );
      return;
    }

    final budget =
        double.tryParse(budgetController.text.trim()) ?? 0;

    final dateText = startDate == null
        ? 'Date not selected'
        : '${startDate!.day}/${startDate!.month}/${startDate!.year}';

    Navigator.pop(
      context,
      {
        'destination': destination,
        'dates': '$dateText • $days days',
        'status': 'Upcoming',
        'budget': budget,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan a Trip'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Where are you going?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: destinationController,
              decoration: _decoration(
                'Destination',
                Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Starting Date',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: 12),
                    Text(
                      startDate == null
                          ? 'Select date'
                          : '${startDate!.day}/${startDate!.month}/${startDate!.year}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Number of Days',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (days > 1) {
                      setState(() => days--);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$days days',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (days < 30) {
                      setState(() => days++);
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'Travel Style',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: travelStyle,
              decoration: _decoration(
                'Travel Style',
                Icons.flight_takeoff_outlined,
              ),
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
                setState(() => travelStyle = value!);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                'Estimated Budget',
                Icons.currency_rupee,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _createTrip,
                icon: const Icon(Icons.add),
                label: const Text('Create Trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}