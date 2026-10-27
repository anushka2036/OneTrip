import 'package:flutter/material.dart';

import '../services/trip_api_service.dart';
import 'edit_trip_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late Map<String, dynamic> _trip;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _trip = Map<String, dynamic>.from(widget.trip);
  }

  // ============================================================
  // GET TRIP ID
  // ============================================================

  String _getTripId() {
    return _trip['id']?.toString() ??
        _trip['_id']?.toString() ??
        _trip['trip_id']?.toString() ??
        '';
  }

  // ============================================================
  // EDIT TRIP
  // ============================================================

  Future<void> _editTrip() async {
    final tripId = _getTripId();

    if (tripId.isEmpty) {
      _showMessage('Cannot edit this trip because its ID is missing.');
      return;
    }

    setState(() {
      _isEditing = true;
    });

    try {
      final updated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => EditTripScreen(trip: _trip)),
      );

      if (!mounted) return;

      if (updated == true) {
        // Fetch the latest version from MongoDB.
        await _refreshTrip();

        if (!mounted) return;

        _showMessage('Trip details updated successfully.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
      }
    }
  }

  // ============================================================
  // REFRESH CURRENT TRIP
  // ============================================================

  Future<void> _refreshTrip() async {
    try {
      final trips = await TripApiService.getTrips();

      final tripId = _getTripId();

      Map<String, dynamic>? latestTrip;

      for (final trip in trips) {
        final currentId =
            trip['id']?.toString() ??
            trip['_id']?.toString() ??
            trip['trip_id']?.toString() ??
            '';

        if (currentId == tripId) {
          latestTrip = trip;
          break;
        }
      }

      if (latestTrip == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _trip = _formatTripForUI(latestTrip!);
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage('Could not refresh trip details. $error');
    }
  }

  // ============================================================
  // FORMAT TRIP
  // ============================================================

  Map<String, dynamic> _formatTripForUI(Map<String, dynamic> trip) {
    final startDate = DateTime.tryParse(trip['start_date']?.toString() ?? '');

    final endDate = DateTime.tryParse(trip['end_date']?.toString() ?? '');

    int days = 1;

    if (startDate != null && endDate != null) {
      days = endDate.difference(startDate).inDays + 1;

      if (days < 1) {
        days = 1;
      }
    }

    final budget = (trip['budget'] as num?)?.toDouble() ?? 0.0;

    final isUpcoming =
        startDate == null ||
        !DateUtils.dateOnly(startDate)
            .isBefore(DateUtils.dateOnly(DateTime.now()));

    return {
      ...trip,
      'location': trip['destination']?.toString() ?? 'Unknown',
      'days': '$days ${days == 1 ? 'Day' : 'Days'}',
      'budget': budget,
      'expense': 0.0,
      'covered': 'Not added yet',
      'status': isUpcoming ? 'Upcoming' : 'Completed',
    };
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');

    if (date == null) {
      return 'Not available';
    }

    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final title = _trip['title']?.toString() ?? 'Untitled Trip';

    final destination =
        _trip['destination']?.toString() ??
        _trip['location']?.toString() ??
        'Unknown';

    final budget = (_trip['budget'] as num?)?.toDouble() ?? 0.0;

    final travelers = _trip['travelers']?.toString() ?? '1';

    final expense = (_trip['expense'] as num?)?.toDouble() ?? 0.0;

    final remaining = budget - expense;

    final days = _trip['days']?.toString() ?? '1 Day';

    final status = _trip['status']?.toString() ?? 'Upcoming';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Edit trip',
            onPressed: _isEditing ? null : _editTrip,
            icon: _isEditing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTrip,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: 19,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          destination,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // TRIP INFORMATION
            // ==================================================
            const Text(
              'Trip Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons.calendar_today_outlined,
                    'Start Date',
                    _formatDate(_trip['start_date']),
                  ),

                  _detailRow(
                    Icons.event_outlined,
                    'End Date',
                    _formatDate(_trip['end_date']),
                  ),

                  _detailRow(Icons.timelapse_outlined, 'Duration', days),

                  _detailRow(Icons.people_outline, 'Travelers', travelers),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // BUDGET
            // ==================================================
            const Text(
              'Budget Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons.account_balance_wallet_outlined,
                    'Total Budget',
                    '₹${budget.toStringAsFixed(0)}',
                  ),

                  _detailRow(
                    Icons.payments_outlined,
                    'Total Expense',
                    '₹${expense.toStringAsFixed(0)}',
                  ),

                  _detailRow(
                    Icons.savings_outlined,
                    'Remaining',
                    '₹${remaining.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // EXPENSE PLACEHOLDER
            // ==================================================
            const Text(
              'Expenses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 42,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'No expenses added yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Expense tracking will be available here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 15),

                  OutlinedButton.icon(
                    onPressed: () {
                      _showMessage(
                        'Expense tracking will be added in the next step.',
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // EDIT BUTTON
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _isEditing ? null : _editTrip,
                icon: const Icon(Icons.edit_outlined),
                label: const Text(
                  'Edit Trip',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
