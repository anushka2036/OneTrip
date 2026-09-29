import 'package:flutter/material.dart';
import 'maps_screen.dart';
import 'plan_trip_screen.dart';
import 'upload_ticket_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // =========================
                    // TOP ICONS
                    // =========================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circleIcon(
                          icon: Icons.notifications_none,
                          onTap: () {},
                        ),
                        _circleIcon(
                          icon: Icons.person_outline,
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // =========================
                    // GREETING
                    // =========================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E1E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Hello, User!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // QUICK ACTIONS
                    // =========================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E1E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [

                          // ADD TRIP
                          _quickAction(
                            icon: Icons.flight_takeoff_outlined,
                            title: 'Add Trip',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PlanTripScreen(),
                                ),
                              );
                            },
                          ),

                          // UPLOAD TICKET
                          _quickAction(
  icon: Icons.receipt_long_outlined,
  title: 'Upload\nTicket',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const UploadTicketScreen(),
      ),
    );
  },
),

                          // NEARBY PLACES
                          _quickAction(
                            icon: Icons.location_on_outlined,
                            title: 'Nearby\nPlaces',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MapsScreen(),
                                ),
                              );
                            },
                          ),

                          // ITINERARY
                          _quickAction(
                            icon: Icons.event_note_outlined,
                            title: 'Itinerary',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =========================
                    // TRIPS TITLE
                    // =========================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Trips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // + BUTTON
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PlanTripScreen(),
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.add,
                            size: 35,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // =========================
                    // TRIP CARD
                    // =========================
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E1E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Trip image
                          SizedBox(
                            height: 155,
                            width: double.infinity,
                            child: Image.network(
                              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
                              fit: BoxFit.cover,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Trip details
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              12,
                              10,
                              10,
                              8,
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        '12/10/2026 - 17/10/2026',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Destination: Manali',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Total Expenses: ₹25,000',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Family Trip',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Status: Upcoming',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // View Trip
                                InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 18,
                                      left: 5,
                                    ),
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.chevron_right,
                                          size: 35,
                                        ),
                                        Text(
                                          'View\nTrip',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Like / Share
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              12,
                              0,
                              12,
                              10,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.thumb_up_alt_outlined,
                                        size: 21,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints:
                                          const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.share_outlined,
                                        size: 21,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints:
                                          const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'More details',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // =========================
            // BOTTOM NAVIGATION
            // =========================
            _bottomNavigationBar(context),
          ],
        ),
      ),
    );
  }

  // =========================================
  // TOP CIRCLE ICON
  // =========================================
// comment
  Widget _circleIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          color: Color(0xFFE1E1E1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 23,
          color: Colors.black87,
        ),
      ),
    );
  }

  // =========================================
  // QUICK ACTION
  // =========================================

 Widget _quickAction({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: SizedBox(
      width: 78,
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: Colors.black87,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

  // =========================================
  // BOTTOM NAVIGATION
  // =========================================

  Widget _bottomNavigationBar(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFE1E1E1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          _bottomItem(
            icon: Icons.home_outlined,
            label: 'Home',
            selected: true,
            onTap: () {},
          ),

          _bottomItem(
  icon: Icons.explore_outlined,
  label: 'Explore',
  selected: false,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExploreScreen(),
      ),
    );
  },
),

          _bottomItem(
            icon: Icons.luggage_outlined,
            label: 'Your Trips',
            selected: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlanTripScreen(),
                ),
              );
            },
          ),

          _bottomItem(
            icon: Icons.map_outlined,
            label: 'Maps',
            selected: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapsScreen(),
                ),
              );
            },
          ),

          _bottomItem(
  icon: Icons.person_outline,
  label: 'Profile',
  selected: false,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  },
),
        ],
      ),
    );
  }

  // =========================================
  // BOTTOM NAV ITEM
  // =========================================

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 35,
              color: selected
                  ? Colors.black
                  : Colors.grey.shade700,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}