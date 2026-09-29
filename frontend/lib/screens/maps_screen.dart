import 'package:flutter/material.dart';

class MapsScreen extends StatelessWidget {
  const MapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nearby',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search places, restaurants...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Location
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE1E1E1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nearby your current location',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.my_location,
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Categories
            const Text(
              'Explore Nearby',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 75,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _category(
                    Icons.tour,
                    'Places',
                  ),
                  _category(
                    Icons.restaurant_outlined,
                    'Restaurants',
                  ),
                  _category(
                    Icons.hotel_outlined,
                    'Hotels',
                  ),
                  _category(
                    Icons.local_cafe_outlined,
                    'Cafes',
                  ),
                  _category(
                    Icons.shopping_bag_outlined,
                    'Shopping',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Map placeholder
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [

                  // Map background
                  Center(
                    child: Icon(
                      Icons.map,
                      size: 70,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  // Current location
                  const Positioned(
                    top: 90,
                    left: 170,
                    child: Icon(
                      Icons.location_on,
                      size: 42,
                      color: Colors.black,
                    ),
                  ),

                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton.small(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      onPressed: () {},
                      child: const Icon(
                        Icons.my_location,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Recommendations
            const Text(
              'Recommended Near You',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _recommendationCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1500534623283-312aade485b7?w=800',
              title: 'Mountain View Point',
              type: 'Tourist Attraction',
              distance: '1.2 km',
              rating: '4.7',
            ),

            const SizedBox(height: 12),

            _recommendationCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
              title: 'Local Restaurant',
              type: 'Restaurant',
              distance: '800 m',
              rating: '4.5',
            ),

            const SizedBox(height: 12),

            _recommendationCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
              title: 'Popular Cafe',
              type: 'Cafe',
              distance: '1.5 km',
              rating: '4.6',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Category button
  Widget _category(
    IconData icon,
    String title,
  ) {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: Colors.black87,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Recommendation card
  Widget _recommendationCard({
    required String imageUrl,
    required String title,
    required String type,
    required String distance,
    required String rating,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE1E1E1),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [

          // Image
          SizedBox(
            width: 115,
            height: 125,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_outlined,
                    size: 40,
                  ),
                );
              },
            ),
          ),

          // Information
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {},
                      child: const Text(
                        'View Details  ›',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}