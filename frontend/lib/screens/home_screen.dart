import 'package:flutter/material.dart';

import '../services/trip_api_service.dart';
import '../services/expense_api_service.dart';

import 'edit_trip_screen.dart';
import 'expense_analyzer_screen.dart';
import 'expenses_screen.dart';
import 'explore_screen.dart';
import 'itinerary_screen.dart';
import 'maps_screen.dart';
import 'notifications_screen.dart';
import 'plan_trip_screen.dart';
import 'profile_screen.dart';
import 'trip_details_screen.dart';
import 'upload_ticket_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> _trips = [];

  bool _isLoadingTrips = true;
  String? _tripsError;

  final Set<String> _deletingTripIds = {};
  final Set<String> _editingTripIds = {};

  // Expense summaries keyed by trip ID.
  final Map<String, Map<String, dynamic>> _expenseSummaries = {};

  final Set<String> _loadingExpenseSummaryIds = {};


  @override
  void initState() {
    super.initState();
    _loadTrips();
  }


  // ============================================================
  // FETCH TRIPS
  // ============================================================

  Future<void> _loadTrips() async {
    if (!mounted) return;

    setState(() {
      _isLoadingTrips = true;
      _tripsError = null;
    });

    try {
      final response = await TripApiService.getTrips();

      if (!mounted) return;

      final formattedTrips =
          response.map(_formatTripForUI).toList();

      setState(() {
        _trips = formattedTrips;
        _isLoadingTrips = false;
      });

      await _loadExpenseSummaries(formattedTrips);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _tripsError = error.toString();
        _isLoadingTrips = false;
      });
    }
  }


  // ============================================================
  // LOAD EXPENSE SUMMARIES
  // ============================================================

  Future<void> _loadExpenseSummaries(
    List<Map<String, dynamic>> trips,
  ) async {
    for (final trip in trips) {
      final tripId =
          trip['id']?.toString() ??
          trip['_id']?.toString() ??
          trip['trip_id']?.toString() ??
          '';

      if (tripId.isEmpty) {
        continue;
      }

      if (!mounted) return;

      setState(() {
        _loadingExpenseSummaryIds.add(tripId);
      });

      try {
        final summary =
            await ExpenseApiService.getExpenseSummary(
          tripId,
        );

        if (!mounted) return;

        setState(() {
          _expenseSummaries[tripId] = summary;
        });
      } catch (_) {
        // Expense summary failure should not prevent
        // the trip list from loading.
      } finally {
        if (mounted) {
          setState(() {
            _loadingExpenseSummaryIds.remove(tripId);
          });
        }
      }
    }
  }


  // ============================================================
  // GET EXPENSE FOR TRIP
  // ============================================================

  double _getTripExpense(String tripId) {
    final summary = _expenseSummaries[tripId];

    if (summary == null) {
      return 0.0;
    }

    return (summary['total_expense'] as num?)
            ?.toDouble() ??
        0.0;
  }


  // ============================================================
  // FORMAT API DATA
  // ============================================================

  Map<String, dynamic> _formatTripForUI(
    Map<String, dynamic> trip,
  ) {
    final startDate =
        DateTime.tryParse(
      trip['start_date']?.toString() ?? '',
    );

    final endDate =
        DateTime.tryParse(
      trip['end_date']?.toString() ?? '',
    );

    int days = 1;

    if (startDate != null && endDate != null) {
      days =
          endDate.difference(startDate).inDays + 1;

      if (days < 1) {
        days = 1;
      }
    }

    final budget =
        (trip['budget'] as num?)
                ?.toDouble() ??
            0.0;

    final isUpcoming =
        startDate == null ||
        !DateUtils.dateOnly(startDate).isBefore(
          DateUtils.dateOnly(
            DateTime.now(),
          ),
        );

    return {
      ...trip,
      'location':
          trip['destination']?.toString() ??
              'Unknown',
      'days':
          '$days ${days == 1 ? 'Day' : 'Days'}',
      'budget': budget,
      'expense': 0.0,
      'covered': 'Not added yet',
      'status':
          isUpcoming ? 'Upcoming' : 'Completed',
    };
  }


  // ============================================================
  // OPEN PLAN TRIP
  // ============================================================

  Future<void> _openPlanTrip() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PlanTripScreen(),
      ),
    );

    if (!mounted) return;

    await _loadTrips();
  }


  // ============================================================
  // OPEN TRIP DETAILS
  // ============================================================

  Future<void> _openTripDetails(
    Map<String, dynamic> trip,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TripDetailsScreen(
          trip: trip,
        ),
      ),
    );

    if (!mounted) return;

    await _loadTrips();
  }


  // ============================================================
  // OPEN EXPENSES
  // ============================================================

  Future<void> _openExpenses(
    Map<String, dynamic> trip,
  ) async {
    final tripId =
        trip['id']?.toString() ??
        trip['_id']?.toString() ??
        trip['trip_id']?.toString() ??
        '';

    if (tripId.isEmpty) {
      _showMessage(
        'Cannot track expenses: trip ID is missing.',
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ExpensesScreen(
          trip: trip,
        ),
      ),
    );

    if (!mounted) return;

    await _loadTrips();
  }


  // ============================================================
  // OPEN EXPENSE ANALYSIS
  // ============================================================

  Future<void> _openExpenseAnalysis(
    Map<String, dynamic> trip,
  ) async {
    final tripId =
        trip['id']?.toString() ??
        trip['_id']?.toString() ??
        trip['trip_id']?.toString() ??
        '';

    if (tripId.isEmpty) {
      _showMessage(
        'Cannot analyze expenses: trip ID is missing.',
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ExpenseAnalyzerScreen(
          trip: trip,
        ),
      ),
    );

    if (!mounted) return;

    await _loadTrips();
  }


  // ============================================================
  // EDIT TRIP
  // ============================================================

  Future<void> _editTrip(
    Map<String, dynamic> trip,
  ) async {
    final tripId =
        trip['id']?.toString() ??
        trip['_id']?.toString() ??
        trip['trip_id']?.toString() ??
        '';

    if (tripId.isEmpty) {
      _showMessage(
        'Cannot edit this trip: its ID is missing.',
      );
      return;
    }

    if (_editingTripIds.contains(tripId)) {
      return;
    }

    setState(() {
      _editingTripIds.add(tripId);
    });

    try {
      final updated =
          await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EditTripScreen(
            trip: trip,
          ),
        ),
      );

      if (!mounted) return;

      if (updated == true) {
        await _loadTrips();

        if (!mounted) return;

        _showMessage(
          'Trip details refreshed successfully.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _editingTripIds.remove(tripId);
        });
      }
    }
  }


  // ============================================================
  // DELETE TRIP
  // ============================================================

  Future<void> _confirmDeleteTrip(
    Map<String, dynamic> trip,
  ) async {
    final tripId =
        trip['id']?.toString() ??
        trip['_id']?.toString() ??
        trip['trip_id']?.toString() ??
        '';

    final destination =
        trip['location']?.toString() ??
            'this trip';

    if (tripId.isEmpty) {
      _showMessage(
        'Cannot delete this trip: its ID is missing.',
      );
      return;
    }

    if (_deletingTripIds.contains(tripId)) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Delete Trip?'),
          content: Text(
            'Are you sure you want to delete your trip to '
            '$destination? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    setState(() {
      _deletingTripIds.add(tripId);
    });

    try {
      await TripApiService.deleteTrip(
        tripId,
      );

      if (!mounted) return;

      setState(() {
        _trips.removeWhere((item) {
          final itemId =
              item['id']?.toString() ??
              item['_id']?.toString() ??
              item['trip_id']?.toString() ??
              '';

          return itemId == tripId;
        });

        _expenseSummaries.remove(
          tripId,
        );
      });

      _showMessage(
        'Trip deleted successfully.',
      );

      await _loadTrips();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Could not delete trip. $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingTripIds.remove(
            tripId,
          );
        });
      }
    }
  }


  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }


  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F7F7),
      body: SafeArea(
        child:
            _selectedIndex == 3
                ? const MapsScreen()
                : _selectedIndex == 1
                    ? const ExploreScreen()
                    : _selectedIndex == 2
                        ? _buildTripsView()
                        : _selectedIndex == 4
                            ? const ProfileScreen()
                            : _buildHomeView(),
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(),
    );
  }


  // ============================================================
  // HOME
  // ============================================================

  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _circleIcon(
                icon:
                    Icons.notifications_none,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const NotificationsScreen(),
                    ),
                  );
                },
              ),
              _circleIcon(
                icon:
                    Icons.person_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            'Hello, Traveller 👋',
            style: TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Where are you going next?',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 24),

          _upcomingTripCard(),

          const SizedBox(height: 25),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          GridView.count(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              _quickAction(
                icon:
                    Icons.add_location_alt_outlined,
                title: 'Add Trip',
                onTap:
                    _openPlanTrip,
              ),
              _quickAction(
                icon:
                    Icons.cloud_upload_outlined,
                title:
                    'Upload Ticket',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const UploadTicketScreen(),
                    ),
                  );
                },
              ),
              _quickAction(
                icon:
                    Icons.map_outlined,
                title:
                    'Nearby Places',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const MapsScreen(),
                    ),
                  );
                },
              ),
              _quickAction(
                icon:
                    Icons.event_note_outlined,
                title:
                    'Itinerary',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ItineraryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            'Travel Tools',
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          _toolCard(
            icon:
                Icons.account_balance_wallet_outlined,
            title:
                'Expense Analyzer',
            subtitle:
                'Estimate how much your trip may cost',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ExpenseAnalyzerScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _toolCard(
            icon:
                Icons.route_outlined,
            title:
                'Your Trips',
            subtitle:
                'View your past and upcoming journeys',
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });

              _loadTrips();
            },
          ),
        ],
      ),
    );
  }


  // ============================================================
  // UPCOMING TRIP
  // ============================================================

  Widget _upcomingTripCard() {
    final upcomingTrips =
        _trips.where(
      (trip) =>
          trip['status'] == 'Upcoming',
    );

    final trip =
        upcomingTrips.isNotEmpty
            ? upcomingTrips.first
            : null;

    if (_isLoadingTrips &&
        _trips.isEmpty) {
      return Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.all(20),
        decoration:
            BoxDecoration(
          color: Colors.black,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                color:
                    Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading your trips...',
              style: TextStyle(
                color:
                    Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (trip == null) {
      return Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.all(20),
        decoration:
            BoxDecoration(
          color: Colors.black,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'UPCOMING TRIP',
              style: TextStyle(
                color:
                    Colors.white70,
                fontSize: 12,
                letterSpacing:
                    1.2,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'No upcoming trips',
              style: TextStyle(
                color:
                    Colors.white,
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a trip to see it here.',
              style: TextStyle(
                color:
                    Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () =>
          _openTripDetails(
        trip,
      ),
      borderRadius:
          BorderRadius.circular(20),
      child: Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.all(20),
        decoration:
            BoxDecoration(
          color: Colors.black,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'UPCOMING TRIP',
              style: TextStyle(
                color:
                    Colors.white70,
                fontSize: 12,
                letterSpacing:
                    1.2,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              trip['location']
                  as String,
              style: const TextStyle(
                color:
                    Colors.white,
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${trip['start_date']}  •  ${trip['days']}',
              style:
                  const TextStyle(
                color:
                    Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Text(
                  'View trip details',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward,
                  color:
                      Colors.white,
                  size: 17,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // YOUR TRIPS
  // ============================================================

  Widget _buildTripsView() {
    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          30,
        ),
        children: [
          const Text(
            'Your Trips',
            style: TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Your travel history and upcoming journeys',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 22),

          if (_isLoadingTrips)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                vertical: 50,
              ),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 14),
                    Text(
                      'Loading your trips...',
                    ),
                  ],
                ),
              ),
            )
          else if (_tripsError != null)
            _buildTripsError()
          else if (_trips.isEmpty)
            _buildEmptyTrips()
          else
            ..._trips.map(
              _tripCard,
            ),
        ],
      ),
    );
  }


  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildTripsError() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 35,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load your trips.',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tripsError!,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed:
                _loadTrips,
            icon:
                const Icon(
              Icons.refresh,
            ),
            label:
                const Text(
              'Retry',
            ),
          ),
        ],
      ),
    );
  }


  // ============================================================
  // EMPTY TRIPS
  // ============================================================

  Widget _buildEmptyTrips() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 45,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.luggage_outlined,
            size: 55,
            color: Colors.grey,
          ),
          const SizedBox(height: 15),
          const Text(
            'You haven’t planned any trips yet.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first trip to see it here.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed:
                _openPlanTrip,
            icon:
                const Icon(
              Icons.add,
            ),
            label:
                const Text(
              'Plan a Trip',
            ),
          ),
        ],
      ),
    );
  }


  // ============================================================
  // TRIP CARD
  // ============================================================

  Widget _tripCard(
    Map<String, dynamic> trip,
  ) {
    final budget =
        (trip['budget'] as num?)
                ?.toDouble() ??
            0.0;

    final tripId =
        trip['id']?.toString() ??
        trip['_id']?.toString() ??
        trip['trip_id']?.toString() ??
        '';

    final expense =
        _getTripExpense(
      tripId,
    );

    final remaining =
        budget - expense;

    final isDeleting =
        _deletingTripIds.contains(
      tripId,
    );

    final isEditing =
        _editingTripIds.contains(
      tripId,
    );

    final isLoadingExpense =
        _loadingExpenseSummaryIds
            .contains(
      tripId,
    );

    return InkWell(
      onTap:
          isDeleting || isEditing
              ? null
              : () =>
                  _openTripDetails(
                    trip,
                  ),
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        width:
            double.infinity,
        margin:
            const EdgeInsets.only(
          bottom: 16,
        ),
        padding:
            const EdgeInsets.all(18),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(
                    11,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    trip['location']
                        as String,
                    style:
                        const TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  trip['status']
                      as String,
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                    fontSize: 12,
                  ),
                ),

                IconButton(
                  tooltip:
                      'Edit trip',
                  onPressed:
                      isEditing ||
                              isDeleting
                          ? null
                          : () =>
                              _editTrip(
                                trip,
                              ),
                  icon: isEditing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Icon(
                          Icons.edit_outlined,
                        ),
                ),

                IconButton(
                  tooltip:
                      'Delete trip',
                  onPressed:
                      isDeleting ||
                              isEditing
                          ? null
                          : () =>
                              _confirmDeleteTrip(
                                trip,
                              ),
                  icon: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Icon(
                          Icons.delete_outline,
                          color:
                              Colors.red,
                        ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            _tripDetailRow(
              Icons.calendar_today_outlined,
              'Duration',
              trip['days']
                  as String,
            ),

            _tripDetailRow(
              Icons.account_balance_wallet_outlined,
              'Budget',
              '₹${budget.toStringAsFixed(0)}',
            ),

            _tripDetailRow(
              Icons.payments_outlined,
              'Total Expense',
              isLoadingExpense
                  ? 'Loading...'
                  : '₹${expense.toStringAsFixed(0)}',
            ),

            _tripDetailRow(
              Icons.savings_outlined,
              'Remaining',
              isLoadingExpense
                  ? 'Loading...'
                  : '₹${remaining.toStringAsFixed(0)}',
            ),

            _tripDetailRow(
              Icons.people_outline,
              'Travelers',
              '${trip['travelers'] ?? 1}',
            ),

            _tripDetailRow(
              Icons.explore_outlined,
              'Locations Covered',
              trip['covered']
                  as String,
            ),

            const SizedBox(
              height: 8,
            ),

            // ==================================================
            // TRACK EXPENSES BUTTON
            // ==================================================

            SizedBox(
              width:
                  double.infinity,
              child:
                  OutlinedButton.icon(
                onPressed:
                    isDeleting ||
                            isEditing
                        ? null
                        : () =>
                            _openExpenses(
                              trip,
                            ),
                icon:
                    const Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  size: 19,
                ),
                label:
                    const Text(
                  'Track Expenses',
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            // ==================================================
            // ANALYZE EXPENSES BUTTON
            // ==================================================

            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton.icon(
                onPressed:
                    isDeleting ||
                            isEditing
                        ? null
                        : () =>
                            _openExpenseAnalysis(
                              trip,
                            ),
                icon:
                    const Icon(
                  Icons.analytics_outlined,
                  size: 19,
                ),
                label:
                    const Text(
                  'Analyze Expenses',
                ),
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            const Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                Text(
                  'View Details',
                  style:
                      TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _tripDetailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color:
                Colors.grey.shade700,
          ),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 105,
            child: Text(
              title,
              style:
                  const TextStyle(
                color:
                    Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        border:
            Border(
          top:
              BorderSide(
            color:
                Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(
              icon:
                  Icons.home_outlined,
              label:
                  'Home',
              selected:
                  _selectedIndex == 0,
              onTap: () {
                setState(
                  () =>
                      _selectedIndex =
                          0,
                );
              },
            ),

            _bottomItem(
              icon:
                  Icons.explore_outlined,
              label:
                  'Explore',
              selected:
                  _selectedIndex == 1,
              onTap: () {
                setState(
                  () =>
                      _selectedIndex =
                          1,
                );
              },
            ),

            _bottomItem(
              icon:
                  Icons.luggage_outlined,
              label:
                  'Your Trips',
              selected:
                  _selectedIndex == 2,
              onTap: () {
                setState(
                  () =>
                      _selectedIndex =
                          2,
                );

                _loadTrips();
              },
            ),

            _bottomItem(
              icon:
                  Icons.map_outlined,
              label:
                  'Maps',
              selected:
                  _selectedIndex == 3,
              onTap: () {
                setState(
                  () =>
                      _selectedIndex =
                          3,
                );
              },
            ),

            _bottomItem(
              icon:
                  Icons.person_outline,
              label:
                  'Profile',
              selected:
                  _selectedIndex == 4,
              onTap: () {
                setState(
                  () =>
                      _selectedIndex =
                          4,
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // CIRCLE ICON
  // ============================================================

  Widget _circleIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:
          onTap,
      borderRadius:
          BorderRadius.circular(50),
      child: Container(
        width: 45,
        height: 45,
        decoration:
            BoxDecoration(
          color:
              Colors.white,
          shape:
              BoxShape.circle,
          border:
              Border.all(
            color:
                Colors.grey.shade200,
          ),
        ),
        child:
            Icon(icon),
      ),
    );
  }


  // ============================================================
  // QUICK ACTION
  // ============================================================

  Widget _quickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:
          onTap,
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
        padding:
            const EdgeInsets.all(15),
        decoration:
            BoxDecoration(
          color:
              Colors.white,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 25,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // TOOL CARD
  // ============================================================

  Widget _toolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:
          onTap,
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.all(17),
        decoration:
            BoxDecoration(
          color:
              Colors.white,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(11),
              decoration:
                  BoxDecoration(
                color:
                    Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child:
                  Icon(icon),
            ),
            const SizedBox(
              width: 14,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
            ),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // BOTTOM ITEM
  // ============================================================

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:
          onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 9,
          horizontal: 7,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? Colors.black
                  : Colors.grey,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              label,
              style:
                  TextStyle(
                fontSize: 10,
                color: selected
                    ? Colors.black
                    : Colors.grey,
                fontWeight:
                    selected
                        ? FontWeight.w600
                        : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}