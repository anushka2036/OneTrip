import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,

        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              _showSettings(context);
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.black,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // =========================================
            // PROFILE INFORMATION
            // =========================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                20,
              ),
              color: const Color(0xFFF7F7F7),

              child: Column(
                children: [

                  // Profile picture
                  CircleAvatar(
                    radius: 52,

                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/300?img=12',
                    ),

                    backgroundColor:
                        Colors.grey.shade300,
                  ),

                  const SizedBox(height: 12),

                  // Name
                  const Text(
                    'Aryan Antad',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Username
                  const Text(
                    '@aryan_travels',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Bio
                  const Text(
                    'Exploring places, creating memories ✈️\n'
                    'Travel • Food • Adventure',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =================================
                  // FOLLOWERS / FOLLOWING / TRIPS
                  // =================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [

                      _statItem(
                        '12',
                        'Trips',
                      ),

                      _statItem(
                        '248',
                        'Followers',
                      ),

                      _statItem(
                        '186',
                        'Following',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // =================================
                  // EDIT PROFILE
                  // =================================

                  SizedBox(
                    width: double.infinity,

                    child: OutlinedButton(
                      onPressed: () {
                        _editProfile(context);
                      },

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

                      child: const Text(
                        'Edit Profile',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================================
            // PROFILE OPTIONS
            // =========================================

            Container(
              color: Colors.white,

              child: Column(
                children: [

                  _profileOption(
                    icon: Icons.luggage_outlined,
                    title: 'My Trips',
                    subtitle:
                        'View your created trips',
                    onTap: () {
                      _showMessage(
                        context,
                        'My Trips will be connected next.',
                      );
                    },
                  ),

                  _profileOption(
                    icon: Icons.bookmark_outline,
                    title: 'Saved Trips',
                    subtitle:
                        'Trips you saved from Explore',
                    onTap: () {
                      _showMessage(
                        context,
                        'Saved Trips will be connected next.',
                      );
                    },
                  ),

                  _profileOption(
                    icon: Icons.favorite_border,
                    title: 'Liked Trips',
                    subtitle:
                        'Trips you liked',
                    onTap: () {
                      _showMessage(
                        context,
                        'Liked Trips will be connected next.',
                      );
                    },
                  ),

                  _profileOption(
                    icon: Icons.photo_library_outlined,
                    title: 'My Posts',
                    subtitle:
                        'Your shared travel posts',
                    onTap: () {
                      _showMessage(
                        context,
                        'My Posts will be connected next.',
                      );
                    },
                  ),

                ],
              ),
            ),

            const SizedBox(height: 15),

            // =========================================
            // MY TRAVEL POSTS
            // =========================================

            Container(
              color: Colors.white,

              padding: const EdgeInsets.only(
                top: 15,
                bottom: 20,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    child: Text(
                      'My Travel Posts',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),

                    itemCount: 6,

                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final images = [
                        'https://images.unsplash.com/photo-1500534623283-312aade485b7?w=500',
                        'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=500',
                        'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=500',
                        'https://images.unsplash.com/photo-1548013146-72479768bada?w=500',
                        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=500',
                        'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=500',
                      ];

                      return GestureDetector(
                        onTap: () {
                          _showMessage(
                            context,
                            'Trip post ${index + 1}',
                          );
                        },

                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,

                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              color:
                                  Colors.grey.shade300,

                              child: const Icon(
                                Icons.image_outlined,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // =========================================
            // LOGOUT
            // =========================================

            Container(
              color: Colors.white,

              padding: const EdgeInsets.all(16),

              child: SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  onPressed: () {
                    _logout(context);
                  },

                  icon: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),

                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.red,
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // =========================================
  // STAT ITEM
  // =========================================

  Widget _statItem(
    String number,
    String label,
  ) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // =========================================
  // PROFILE OPTION
  // =========================================

  Widget _profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),

        child: Row(
          children: [

            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: Icon(
                icon,
                color: Colors.black87,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // EDIT PROFILE
  // =========================================

  void _editProfile(BuildContext context) {
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
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
                MediaQuery.of(context)
                        .viewInsets
                        .bottom +
                    20,
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                decoration:
                    const InputDecoration(
                  labelText: 'Name',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                decoration:
                    const InputDecoration(
                  labelText: 'Username',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                maxLines: 2,
                decoration:
                    const InputDecoration(
                  labelText: 'Bio',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),

                  child: const Text(
                    'Save Changes',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================
  // SETTINGS
  // =========================================

  void _showSettings(BuildContext context) {
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
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.notifications_outlined,
                ),
                title: const Text(
                  'Notifications',
                ),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(
                  Icons.lock_outline,
                ),
                title: const Text(
                  'Privacy',
                ),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(
                  Icons.help_outline,
                ),
                title: const Text(
                  'Help & Support',
                ),
                onTap: () {},
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // =========================================
  // LOGOUT
  // =========================================

  void _logout(BuildContext context) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),

          content: const Text(
            'Are you sure you want to logout?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                _showMessage(
                  context,
                  'Logout will be connected to authentication later.',
                );
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================
  // MESSAGE
  // =========================================

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        duration:
            const Duration(seconds: 2),
      ),
    );
  }
}