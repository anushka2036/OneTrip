// lib/screens/explore_screen.dart

import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<Map<String, dynamic>> posts = [
    {
      'name': 'Rahul Sharma',
      'username': '@rahultravels',
      'destination': 'Manali, Himachal Pradesh',
      'title': '5 Days in Manali',
      'description':
          'A complete Manali itinerary covering mountains, cafes, temples and adventure activities.',
      'budget': '₹18,500',
      'days': '5 Days',
      'places': '12 Places',
      'likes': 248,
      'comments': 31,
      'liked': false,
    },
    {
      'name': 'Sneha Patil',
      'username': '@snehaexplores',
      'destination': 'Goa',
      'title': 'Budget Goa Weekend',
      'description':
          'Two friends, three beaches, amazing food and a simple budget-friendly weekend.',
      'budget': '₹9,800',
      'days': '3 Days',
      'places': '7 Places',
      'likes': 412,
      'comments': 45,
      'liked': false,
    },
    {
      'name': 'Aditya Mehta',
      'username': '@adityagoes',
      'destination': 'Jaipur, Rajasthan',
      'title': 'Royal Jaipur',
      'description':
          'Exploring forts, markets, local food and beautiful historical places.',
      'budget': '₹13,200',
      'days': '4 Days',
      'places': '15 Places',
      'likes': 189,
      'comments': 18,
      'liked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPost,
        icon: const Icon(Icons.add),
        label: const Text('Share Journey'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 90),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _postCard(index);
        },
      ),
    );
  }

  Widget _postCard(int index) {
    final post = posts[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(
              post['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(post['username']),
            trailing: const Icon(Icons.more_horiz),
          ),
          Container(
            height: 190,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: const Icon(
              Icons.landscape_outlined,
              size: 70,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 5),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      post['liked'] = !post['liked'];
                      post['likes'] += post['liked'] ? 1 : -1;
                    });
                  },
                  icon: Icon(
                    post['liked']
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
                Text('${post['likes']}'),
                const SizedBox(width: 15),
                const Icon(Icons.chat_bubble_outline),
                const SizedBox(width: 7),
                Text('${post['comments']}'),
                const Spacer(),
                const Icon(Icons.bookmark_border),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 2, 15, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['destination'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  post['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post['description'],
                  style: const TextStyle(height: 1.4),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _tag(Icons.currency_rupee, post['budget']),
                    _tag(Icons.calendar_month_outlined, post['days']),
                    _tag(Icons.location_on_outlined, post['places']),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _viewItinerary(post),
                      child: const Text('View Itinerary'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View Expenses'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _viewItinerary(Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SharedItineraryScreen(post: post),
      ),
    );
  }

  void _createPost() {
    final titleController = TextEditingController();
    final destinationController = TextEditingController();
    final descriptionController = TextEditingController();
    final budgetController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Share Your Journey',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _modalField(
                  titleController,
                  'Post Title',
                ),
                _modalField(
                  destinationController,
                  'Destination',
                ),
                _modalField(
                  descriptionController,
                  'Travel Details',
                ),
                _modalField(
                  budgetController,
                  'Budget',
                  number: true,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty ||
                          destinationController.text.trim().isEmpty) {
                        return;
                      }

                      setState(() {
                        posts.insert(0, {
                          'name': 'You',
                          'username': '@yourjourney',
                          'destination':
                              destinationController.text.trim(),
                          'title': titleController.text.trim(),
                          'description':
                              descriptionController.text.trim(),
                          'budget':
                              '₹${budgetController.text.trim().isEmpty ? '0' : budgetController.text.trim()}',
                          'days': 'New Trip',
                          'places': 'Places covered',
                          'likes': 0,
                          'comments': 0,
                          'liked': false,
                        });
                      });

                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Publish Post'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _modalField(
    TextEditingController controller,
    String hint, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType:
            number ? TextInputType.number : TextInputType.text,
        maxLines: hint == 'Travel Details' ? 3 : 1,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _SharedItineraryScreen extends StatelessWidget {
  final Map<String, dynamic> post;

  const _SharedItineraryScreen({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Journey'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            post['title'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            post['destination'],
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _info('Budget', post['budget']),
          _info('Duration', post['days']),
          _info('Places', post['places']),
          const SizedBox(height: 20),
          const Text(
            'Travel Details',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post['description'],
            style: const TextStyle(
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle_outline),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}