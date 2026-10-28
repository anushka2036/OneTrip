import 'package:flutter/material.dart';

import '../services/trip_api_service.dart';

class EditTripScreen extends StatefulWidget {
  final Map<String, dynamic> trip;

  const EditTripScreen({super.key, required this.trip});

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _destinationController;
  late final TextEditingController _budgetController;
  late final TextEditingController _travelersController;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.trip['title']?.toString() ?? '',
    );

    _destinationController = TextEditingController(
      text:
          widget.trip['destination']?.toString() ??
          widget.trip['location']?.toString() ??
          '',
    );

    _budgetController = TextEditingController(text: _initialBudget());

    _travelersController = TextEditingController(
      text: widget.trip['travelers']?.toString() ?? '1',
    );

    _startDate = _parseDate(widget.trip['start_date']);
    _endDate = _parseDate(widget.trip['end_date']);
  }

  String _initialBudget() {
    final budget = widget.trip['budget'];

    if (budget is num) {
      return budget.toStringAsFixed(0);
    }

    return budget?.toString() ?? '';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _travelersController.dispose();

    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();

    final initialDate = _startDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _startDate = picked;

      // If the current end date is before the new start date,
      // clear it so the user can select a valid end date.
      if (_endDate != null && _endDate!.isBefore(picked)) {
        _endDate = null;
      }
    });
  }

  Future<void> _selectEndDate() async {
    final firstDate = _startDate ?? DateTime.now();

    final initialDate = _endDate != null && !_endDate!.isBefore(firstDate)
        ? _endDate!
        : firstDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _endDate = picked;
    });
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Future<void> _updateTrip() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      _showMessage('Please select a start date.');
      return;
    }

    if (_endDate == null) {
      _showMessage('Please select an end date.');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showMessage('End date cannot be before start date.');
      return;
    }

    final budget = double.tryParse(_budgetController.text.trim());

    if (budget == null || budget < 0) {
      _showMessage('Please enter a valid budget.');
      return;
    }

    final travelers = int.tryParse(_travelersController.text.trim());

    if (travelers == null || travelers < 1) {
      _showMessage('Number of travelers must be at least 1.');
      return;
    }

    final tripId =
        widget.trip['id']?.toString() ??
        widget.trip['_id']?.toString() ??
        widget.trip['trip_id']?.toString() ??
        '';

    if (tripId.isEmpty) {
      _showMessage('Cannot update this trip because its ID is missing.');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await TripApiService.updateTrip(
        tripId: tripId,
        title: _titleController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        budget: budget,
        travelers: travelers,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Tell HomeScreen that the trip was updated.
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showMessage('Could not update trip. $error');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Edit Trip'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            children: [
              const Text(
                'Update your trip details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Make changes to your trip and save them.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 25),

              // TRIP TITLE
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Trip Title',
                  hintText: 'Example: Goa Vacation',
                  prefixIcon: const Icon(Icons.title_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a trip title.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // DESTINATION
              TextFormField(
                controller: _destinationController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Destination',
                  hintText: 'Example: Goa',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a destination.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // START DATE
              InkWell(
                onTap: _isUpdating ? null : _selectStartDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Date',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateForDisplay(_startDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // END DATE
              InkWell(
                onTap: _isUpdating ? null : _selectEndDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End Date',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateForDisplay(_endDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // BUDGET
              TextFormField(
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Budget',
                  hintText: 'Example: 25000',
                  prefixText: '₹ ',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your budget.';
                  }

                  final budget = double.tryParse(value.trim());

                  if (budget == null || budget < 0) {
                    return 'Enter a valid budget.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // TRAVELERS
              TextFormField(
                controller: _travelersController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Number of Travelers',
                  hintText: 'Example: 2',
                  prefixIcon: const Icon(Icons.people_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter number of travelers.';
                  }

                  final travelers = int.tryParse(value.trim());

                  if (travelers == null || travelers < 1) {
                    return 'Enter at least 1 traveler.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              // UPDATE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isUpdating ? null : _updateTrip,
                  child: _isUpdating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Updating...'),
                          ],
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // CANCEL BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isUpdating
                      ? null
                      : () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
