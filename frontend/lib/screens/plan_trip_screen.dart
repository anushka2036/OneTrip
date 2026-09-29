import 'package:flutter/material.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController destinationController =
      TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  List<String> itinerary = [
    'Day 1: Location 1',
    'Day 2: Location 2',
  ];

  Future<void> selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      if (isStartDate) {
        startDate = picked;
      } else {
        endDate = picked;
      }
    });
  }

  void addDay() {
    setState(() {
      itinerary.add('Day ${itinerary.length + 1}: Location');
    });
  }

  @override
  void dispose() {
    tripNameController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 45,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Plan Trip',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Trip Name
            TextField(
              controller: tripNameController,
              decoration: InputDecoration(
                hintText: 'Trip Name',
                filled: true,
                fillColor: const Color(0xFFF4EEEE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Dates
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => selectDate(true),
                    child: dateBox(
                      startDate == null
                          ? 'Start Date'
                          : '${startDate!.day}/${startDate!.month}/${startDate!.year}',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: InkWell(
                    onTap: () => selectDate(false),
                    child: dateBox(
                      endDate == null
                          ? 'End Date'
                          : '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Destination
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                hintText: 'Destination',
                filled: true,
                fillColor: const Color(0xFFF4EEEE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Itinerary heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Itinerary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                IconButton(
                  onPressed: addDay,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // Itinerary cards
            ...itinerary.map(
              (day) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Add location button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location selection will be added next.'),
                    ),
                  );
                },
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Add Location'),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) return;

          Navigator.pop(context);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt_outlined),
            label: 'Plan Trip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget dateBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEEE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}