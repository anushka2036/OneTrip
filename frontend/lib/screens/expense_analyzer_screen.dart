// lib/screens/expense_analyzer_screen.dart

import 'package:flutter/material.dart';

class ExpenseAnalyzerScreen extends StatefulWidget {
  const ExpenseAnalyzerScreen({super.key});

  @override
  State<ExpenseAnalyzerScreen> createState() =>
      _ExpenseAnalyzerScreenState();
}

class _ExpenseAnalyzerScreenState extends State<ExpenseAnalyzerScreen> {
  final TextEditingController _locationController =
      TextEditingController();
  final TextEditingController _budgetController =
      TextEditingController();

  bool _hasResult = false;
  double _budget = 0;

  double _hotel = 0;
  double _food = 0;
  double _transport = 0;
  double _entryFees = 0;
  double _activities = 0;
  double _miscellaneous = 0;

  @override
  void dispose() {
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _analyzeBudget() {
    final budget = double.tryParse(_budgetController.text.trim());

    if (_locationController.text.trim().isEmpty || budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location and a valid budget.'),
        ),
      );
      return;
    }

    setState(() {
      _budget = budget;

      _hotel = budget * 0.30;
      _food = budget * 0.20;
      _transport = budget * 0.15;
      _entryFees = budget * 0.10;
      _activities = budget * 0.20;
      _miscellaneous = budget * 0.05;

      _hasResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Expense Analyzer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan Your Expenses',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your destination and total budget. OneTrip will generate an estimated expense breakdown.',
              style: TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            _inputField(
              controller: _locationController,
              label: 'Destination',
              hint: 'e.g. Manali',
              icon: Icons.location_on_outlined,
            ),

            const SizedBox(height: 16),

            _inputField(
              controller: _budgetController,
              label: 'Total Budget',
              hint: 'e.g. 25000',
              icon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _analyzeBudget,
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  'Analyze My Budget',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            if (_hasResult) ...[
              const SizedBox(height: 30),

              Text(
                'Estimated Budget for ${_locationController.text.trim()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Total budget: ₹${_budget.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 18),

              _expenseCard(
                title: 'Hotel / Stay',
                amount: _hotel,
                percentage: 30,
                icon: Icons.hotel_outlined,
              ),

              _expenseCard(
                title: 'Food',
                amount: _food,
                percentage: 20,
                icon: Icons.restaurant_outlined,
              ),

              _expenseCard(
                title: 'Transport',
                amount: _transport,
                percentage: 15,
                icon: Icons.directions_car_outlined,
              ),

              _expenseCard(
                title: 'Entry Fees',
                amount: _entryFees,
                percentage: 10,
                icon: Icons.confirmation_number_outlined,
              ),

              _expenseCard(
                title: 'Activities',
                amount: _activities,
                percentage: 20,
                icon: Icons.local_activity_outlined,
              ),

              _expenseCard(
                title: 'Miscellaneous',
                amount: _miscellaneous,
                percentage: 5,
                icon: Icons.more_horiz,
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'AI integration will later use the destination, trip duration, travel style and other factors to produce a more personalized expense prediction.',
                  style: TextStyle(
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _expenseCard({
    required String title,
    required double amount,
    required int percentage,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$percentage% of budget',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}