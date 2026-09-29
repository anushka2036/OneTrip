import 'package:flutter/material.dart';

class ExpenseAnalyzerScreen extends StatefulWidget {
  const ExpenseAnalyzerScreen({super.key});

  @override
  State<ExpenseAnalyzerScreen> createState() =>
      _ExpenseAnalyzerScreenState();
}

class _ExpenseAnalyzerScreenState
    extends State<ExpenseAnalyzerScreen> {
  final TextEditingController destinationController =
      TextEditingController();

  final TextEditingController budgetController =
      TextEditingController();

  final TextEditingController daysController =
      TextEditingController();

  final TextEditingController peopleController =
      TextEditingController(text: '2');

  @override
  void dispose() {
    destinationController.dispose();
    budgetController.dispose();
    daysController.dispose();
    peopleController.dispose();
    super.dispose();
  }

  void analyzeExpenses() {
    FocusScope.of(context).unfocus();

    if (destinationController.text.isEmpty ||
        budgetController.text.isEmpty ||
        daysController.text.isEmpty ||
        peopleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields'),
        ),
      );
      return;
    }

    final double? budget =
        double.tryParse(budgetController.text);

    final int? days =
        int.tryParse(daysController.text);

    final int? people =
        int.tryParse(peopleController.text);

    if (budget == null || days == null || people == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers'),
        ),
      );
      return;
    }

    final double hotelCost =
        budget * 0.30;

    final double foodCost =
        budget * 0.20;

    final double transportCost =
        budget * 0.15;

    final double activitiesCost =
        budget * 0.20;

    final double entryFees =
        budget * 0.10;

    final double miscellaneous =
        budget * 0.05;

    final double total =
        hotelCost +
        foodCost +
        transportCost +
        activitiesCost +
        entryFees +
        miscellaneous;

    final double remaining =
        budget - total;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expense Analysis',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '$days days • $people people',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                _expenseRow(
                  'Hotel',
                  hotelCost,
                ),

                _expenseRow(
                  'Food',
                  foodCost,
                ),

                _expenseRow(
                  'Transport',
                  transportCost,
                ),

                _expenseRow(
                  'Activities',
                  activitiesCost,
                ),

                _expenseRow(
                  'Entry Fees',
                  entryFees,
                ),

                _expenseRow(
                  'Miscellaneous',
                  miscellaneous,
                ),

                const Divider(height: 30),

                _expenseRow(
                  'Estimated Total',
                  total,
                  bold: true,
                ),

                _expenseRow(
                  'Remaining Budget',
                  remaining,
                  bold: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _expenseRow(
    String title,
    double amount, {
    bool bold = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analyzer'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan Your Travel Budget',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Enter your trip details to estimate your expenses.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                hintText: 'e.g. Goa',
                border: OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.location_on_outlined),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: budgetController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Budget',
                hintText: 'e.g. 25000',
                border: OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.currency_rupee),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: daysController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Days',
                hintText: 'e.g. 4',
                border: OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.calendar_today_outlined),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: peopleController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of People',
                border: OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.people_outline),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: analyzeExpenses,
                child: const Text(
                  'Analyze Expenses',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}