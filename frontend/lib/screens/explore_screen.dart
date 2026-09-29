import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Dummy posts for now.
  // Later these will come from your backend API.

  final List<Map<String, dynamic>> posts = [
    {
      'username': 'travel_with_rahul',
      'profileImage':
          'https://i.pravatar.cc/150?img=12',
      'tripImage':
          'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=1000',
      'destination': 'Manali, Himachal Pradesh',
      'dates': '12 Oct - 17 Oct 2026',
      'caption':
          '5 amazing days in Manali! Sharing my complete itinerary and expenses so you can plan your trip easily.',
      'likes': 248,
      'liked': false,
      'saved': false,
      'budget': '₹25,000',
      'hotel': 'Hotel Mountain View',
      'restaurant': 'Johnson\'s Cafe',
      'days': [
        'Day 1 - Mall Road & Hadimba Temple',
        'Day 2 - Solang Valley',
        'Day 3 - Rohtang Pass',
        'Day 4 - Old Manali & Cafes',
        'Day 5 - Local Shopping & Departure',
      ],
    },
    {
      'username': 'wanderer_anjali',
      'profileImage':
          'https://i.pravatar.cc/150?img=47',
      'tripImage':
          'https://images.unsplash.com/photo-1548013146-72479768bada?w=1000',
      'destination': 'Jaipur, Rajasthan',
      'dates': '05 Nov - 08 Nov 2026',
      'caption':
          'A budget-friendly Jaipur trip with beautiful places, local food and some amazing cafes.',
      'likes': 186,
      'liked': false,
      'saved': false,
      'budget': '₹12,500',
      'hotel': 'The Pink Palace Hotel',
      'restaurant': 'Chokhi Dhani',
      'days': [
        'Day 1 - Hawa Mahal & City Palace',
        'Day 2 - Amber Fort & Jal Mahal',
        'Day 3 - Markets & Local Food',
        'Day 4 - Nahargarh Fort & Departure',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,

        title: const Text(
          'Explore',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 20,
        ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _tripPost(posts[index], index);
        },
      ),
    );
  }

  // =========================================================
  // TRIP POST
  // =========================================================

  Widget _tripPost(
    Map<String, dynamic> post,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      color: Colors.white,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // =================================================
          // USER PROFILE
          // =================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),

            child: Row(
              children: [

                CircleAvatar(
                  radius: 22,

                  backgroundImage:
                      NetworkImage(
                    post['profileImage'],
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        post['username'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                          ),

                          const SizedBox(width: 3),

                          Expanded(
                            child: Text(
                              post['destination'],
                              style:
                                  const TextStyle(
                                fontSize: 11,
                                color:
                                    Colors.black54,
                              ),
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    _showPostMenu();
                  },
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                ),
              ],
            ),
          ),

          // =================================================
          // TRIP IMAGE
          // =================================================

          SizedBox(
            width: double.infinity,
            height: 300,

            child: Image.network(
              post['tripImage'],
              fit: BoxFit.cover,

              errorBuilder:
                  (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,

                  child: const Icon(
                    Icons.image_outlined,
                    size: 60,
                  ),
                );
              },
            ),
          ),

          // =================================================
          // ACTION BUTTONS
          // =================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              8,
              12,
              4,
            ),

            child: Row(
              children: [

                // LIKE
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(),

                  onPressed: () {
                    setState(() {
                      if (post['liked'] == true) {
                        post['liked'] = false;
                        post['likes']--;
                      } else {
                        post['liked'] = true;
                        post['likes']++;
                      }
                    });
                  },

                  icon: Icon(
                    post['liked'] == true
                        ? Icons.favorite
                        : Icons.favorite_border,

                    color: post['liked'] == true
                        ? Colors.red
                        : Colors.black,

                    size: 27,
                  ),
                ),

                const SizedBox(width: 15),

                // COMMENT
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(),

                  onPressed: () {
                    _showMessage(
                      'Comments will be added later.',
                    );
                  },

                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 15),

                // SHARE
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(),

                  onPressed: () {
                    _shareTrip(post);
                  },

                  icon: const Icon(
                    Icons.send_outlined,
                    size: 25,
                  ),
                ),

                const Spacer(),

                // SAVE
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(),

                  onPressed: () {
                    setState(() {
                      post['saved'] =
                          !(post['saved'] == true);
                    });

                    _showMessage(
                      post['saved'] == true
                          ? 'Trip saved!'
                          : 'Trip removed from saved trips.',
                    );
                  },

                  icon: Icon(
                    post['saved'] == true
                        ? Icons.bookmark
                        : Icons.bookmark_border,

                    size: 27,
                  ),
                ),
              ],
            ),
          ),

          // =================================================
          // LIKES
          // =================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),

            child: Text(
              '${post['likes']} likes',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // =================================================
          // CAPTION
          // =================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),

            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),

                children: [

                  TextSpan(
                    text: '${post['username']} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  TextSpan(
                    text: post['caption'],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // =================================================
          // TRIP DETAILS
          // =================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),

            child: Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),

                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    'Trip Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '📅  ${post['dates']}',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    '💰  Budget: ${post['budget']}',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    '🏨  ${post['hotel']}',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    '🍴  ${post['restaurant']}',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // =================================================
          // VIEW ITINERARY
          // =================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),

            child: SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  _showItinerary(post);
                },

                icon: const Icon(
                  Icons.route_outlined,
                  size: 19,
                ),

                label: const Text(
                  'View Full Itinerary',
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(
                    color: Colors.black,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // =================================================
          // USE THIS TRIP
          // =================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),

            child: SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  _useThisTrip(post);
                },

                icon: const Icon(
                  Icons.add_road,
                  size: 19,
                ),

                label: const Text(
                  'Use This Trip',
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // =========================================================
  // FULL ITINERARY
  // =========================================================

  void _showItinerary(
    Map<String, dynamic> post,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape:
          const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Row(
                children: [

                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage(
                      post['profileImage'],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      '${post['username']} - Itinerary',
                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                post['destination'],
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                post['dates'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 15),

              ...List.generate(
                post['days'].length,
                (index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Container(
                          width: 28,
                          height: 28,

                          decoration:
                              const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),

                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            post['days'][index],
                            style:
                                const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 5),

              Text(
                'Total Budget: ${post['budget']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _useThisTrip(post);
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),

                  child: const Text(
                    'Use This Trip',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // USE THIS TRIP
  // =========================================================

  void _useThisTrip(
    Map<String, dynamic> post,
  ) {
    _showMessage(
      'Trip saved! You can use this itinerary when planning your trip.',
    );
  }

  // =========================================================
  // SHARE
  // =========================================================

  void _shareTrip(
    Map<String, dynamic> post,
  ) {
    showModalBottomSheet(
      context: context,

      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Share Trip',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.chat,
                ),

                title: const Text(
                  'Share with OneTrip user',
                ),

                onTap: () {
                  Navigator.pop(context);

                  _showMessage(
                    'OneTrip sharing will be connected to the backend.',
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.send,
                ),

                title: const Text(
                  'Share to WhatsApp',
                ),

                onTap: () {
                  Navigator.pop(context);

                  _showMessage(
                    'WhatsApp sharing will be connected next.',
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.link,
                ),

                title: const Text(
                  'Copy trip link',
                ),

                onTap: () {
                  Navigator.pop(context);

                  _showMessage(
                    'Trip link copied.',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // POST MENU
  // =========================================================

  void _showPostMenu() {
    showModalBottomSheet(
      context: context,

      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              ListTile(
                leading: const Icon(
                  Icons.bookmark_border,
                ),
                title: const Text(
                  'Save post',
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.report_outlined,
                ),
                title: const Text(
                  'Report',
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}