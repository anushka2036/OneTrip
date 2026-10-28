import 'package:flutter/material.dart';

import '../services/trip_api_service.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final destinationController = TextEditingController();
  final budgetController = TextEditingController();

  int days = 3;
  int travelers = 1;
  String travelStyle = 'Balanced';
  DateTime? startDate;

  bool isLoading = false;

  @override
  void dispose() {
    destinationController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final today = DateUtils.dateOnly(DateTime.now());

    final date = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(2035),
      initialDate: startDate ?? today,
    );

    if (date != null && mounted) {
      setState(() {
        startDate = date;
      });
    }
  }

  Future<void> _createTrip() async {
    if (isLoading) return;

    final destination = destinationController.text.trim();
    final budgetText = budgetController.text.trim();

    // 1. Validate destination.
    if (destination.isEmpty) {
      _showMessage('Please enter a destination.');
      return;
    }

    // 2. Validate starting date.
    if (startDate == null) {
      _showMessage('Please select a starting date.');
      return;
    }

    // 3. Validate budget.
    final budget = double.tryParse(budgetText);

    if (budget == null || !budget.isFinite || budget <= 0) {
      _showMessage('Please enter a valid budget greater than ₹0.');
      return;
    }

    // The starting date counts as day 1.
    // For a 3-day trip, end date = start date + 2 days.
    final selectedStartDate = startDate!;
    final endDate = selectedStartDate.add(Duration(days: days - 1));

    // The backend requires a title.
    // The current UI does not have a separate title field.
    final title = 'Trip to $destination';

    setState(() {
      isLoading = true;
    });

    try {
      // 4. Send the trip to FastAPI.
      // FastAPI saves it in MongoDB Atlas.
      final savedTrip = await TripApiService.createTrip(
        title: title,
        destination: destination,
        startDate: selectedStartDate,
        endDate: endDate,
        budget: budget,
        travelers: travelers,
      );

      if (!mounted) return;

      final formattedDate =
          '${selectedStartDate.day.toString().padLeft(2, '0')}/'
          '${selectedStartDate.month.toString().padLeft(2, '0')}/'
          '${selectedStartDate.year}';

      // 5. Show success only after FastAPI returns success.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip created and saved successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 6. Return the saved trip to the previous screen.
      // Include both API fields and UI-friendly fields.
      Navigator.pop(context, {
        ...savedTrip,
        'destination': destination,
        'startDate': selectedStartDate.toIso8601String(),
        'dates': '$formattedDate • $days days',
        'days': days,
        'travelers': travelers,
        'travelStyle': travelStyle,
        'budget': budget,
        'status': 'Upcoming',
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage('Could not save trip: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: destinationController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _decoration(
                'Destination',
                Icons.location_on_outlined,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Starting Date',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: isLoading ? null : _selectDate,
              borderRadius: BorderRadius.circular(12),
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
                          : '${startDate!.day.toString().padLeft(2, '0')}/'
                                '${startDate!.month.toString().padLeft(2, '0')}/'
                                '${startDate!.year}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Number of Days',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                IconButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (days > 1) {
                            setState(() {
                              days--;
                            });
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
                  onPressed: isLoading
                      ? null
                      : () {
                          if (days < 30) {
                            setState(() {
                              days++;
                            });
                          }
                        },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              'Number of Travelers',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                IconButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (travelers > 1) {
                            setState(() {
                              travelers--;
                            });
                          }
                        },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$travelers '
                  '${travelers == 1 ? 'traveler' : 'travelers'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (travelers < 20) {
                            setState(() {
                              travelers++;
                            });
                          }
                        },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              'Travel Style',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: travelStyle,
              decoration: _decoration(
                'Travel Style',
                Icons.flight_takeoff_outlined,
              ),
              items: ['Budget', 'Balanced', 'Luxury', 'Adventure', 'Relaxed']
                  .map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  })
                  .toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          travelStyle = value;
                        });
                      }
                    },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: budgetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              decoration: _decoration('Estimated Budget', Icons.currency_rupee),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _createTrip,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(isLoading ? 'Saving Trip...' : 'Create Trip'),
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
