
import 'package:flutter/material.dart';

import '../services/expense_api_service.dart';

class ExpenseAnalyzerScreen extends StatefulWidget {
  final Map<String, dynamic>? trip;

  const ExpenseAnalyzerScreen({
    super.key,
    this.trip,
  });

  @override
  State<ExpenseAnalyzerScreen> createState() =>
      _ExpenseAnalyzerScreenState();
}

class _ExpenseAnalyzerScreenState
    extends State<ExpenseAnalyzerScreen> {
  bool _isLoading = true;

  String? _errorMessage;

  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  // ============================================================
  // GET TRIP ID
  // ============================================================

  String get _tripId {
    final trip = widget.trip;

    if (trip == null) {
      return '';
    }

    return (trip['id'] ??
            trip['_id'] ??
            trip['trip_id'] ??
            '')
        .toString()
        .trim();
  }

  // ============================================================
  // LOAD EXPENSE SUMMARY
  // ============================================================

  Future<void> _loadSummary() async {
    if (_tripId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _summary = null;
        _errorMessage =
            'Trip information is missing. Open Expense Analysis '
            'from one of your trips.';
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary =
          await ExpenseApiService.getExpenseSummary(_tripId);

      if (!mounted) return;

      setState(() {
        _summary = summary;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  // ============================================================
  // GET TRIP NAME
  // ============================================================

  String get _tripName {
    final trip = widget.trip;

    if (trip == null) {
      return 'Your Trip';
    }

    final location = trip['location']?.toString().trim();
    final destination = trip['destination']?.toString().trim();

    if (location != null && location.isNotEmpty) {
      return location;
    }

    if (destination != null && destination.isNotEmpty) {
      return destination;
    }

    return 'Your Trip';
  }

  // ============================================================
  // NUMBER HELPERS
  // ============================================================

  double _getDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Expense Analysis',
          style: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadSummary,
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Loading expense analysis...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_summary == null) {
      return const Center(
        child: Text('No expense summary available.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSummary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripHeader(),
            const SizedBox(height: 18),
            _buildBudgetOverview(),
            const SizedBox(height: 16),
            _buildBudgetUsage(),
            const SizedBox(height: 16),
            _buildCategoryBreakdown(),
            const SizedBox(height: 16),
            _buildInsights(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TRIP HEADER
  // ============================================================

  Widget _buildTripHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXPENSE ANALYSIS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            _tripName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Understand your spending and remaining travel budget.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUDGET OVERVIEW
  // ============================================================

  Widget _buildBudgetOverview() {
    final summary = _summary!;

    final budget = _getDouble(summary['budget']);
    final totalExpense = _getDouble(summary['total_expense']);
    final remainingBudget = _getDouble(summary['remaining_budget']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _summaryCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Budget',
                value: _formatCurrency(budget),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                icon: Icons.payments_outlined,
                title: 'Spent',
                value: _formatCurrency(totalExpense),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _summaryCard(
          icon: remainingBudget >= 0
              ? Icons.savings_outlined
              : Icons.warning_amber_outlined,
          title: remainingBudget >= 0
              ? 'Remaining Budget'
              : 'Over Budget',
          value: _formatCurrency(remainingBudget.abs()),
          valueColor:
              remainingBudget >= 0 ? Colors.black : Colors.red,
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 23,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUDGET USAGE
  // ============================================================

  Widget _buildBudgetUsage() {
    final summary = _summary!;

    final budget = _getDouble(summary['budget']);
    final totalExpense = _getDouble(summary['total_expense']);

    double percentage =
        _getDouble(summary['budget_used_percentage']);

    // Calculate a fallback if the API doesn't provide a percentage.
    if (budget > 0 && !summary.containsKey('budget_used_percentage')) {
      percentage = (totalExpense / budget) * 100;
    }

    final double progress = budget > 0
        ? (totalExpense / budget).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Budget Usage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 100 ? Colors.red : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            percentage > 100
                ? 'You have exceeded your trip budget.'
                : '${percentage.toStringAsFixed(1)}% of your trip budget has been used.',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY BREAKDOWN
  // ============================================================

  Widget _buildCategoryBreakdown() {
    final rawCategories = _summary!['category_totals'];

    final Map<String, double> categories = {};

    if (rawCategories is Map) {
      rawCategories.forEach((key, value) {
        categories[key.toString()] = _getDouble(value);
      });
    }

    if (categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14),
            Text(
              'No expenses have been added yet.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalExpense = _getDouble(_summary!['total_expense']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'See where your trip money is going.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          ...sortedCategories.map((entry) {
            final double categoryPercentage = totalExpense > 0
                ? (entry.value / totalExpense) * 100
                : 0.0;

            return _categoryRow(
              category: entry.key,
              amount: entry.value,
              percentage: categoryPercentage,
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY ROW
  // ============================================================

  Widget _categoryRow({
    required String category,
    required double amount,
    required double percentage,
  }) {
    final double progress =
        (percentage / 100).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                _formatCurrency(amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INSIGHTS
  // ============================================================

  Widget _buildInsights() {
    final summary = _summary!;

    final totalExpense = _getDouble(summary['total_expense']);
    final remainingBudget = _getDouble(summary['remaining_budget']);
    final percentage = _getDouble(summary['budget_used_percentage']);

    final rawCategories = summary['category_totals'];

    String? highestCategory;
    double highestAmount = 0.0;

    if (rawCategories is Map) {
      rawCategories.forEach((key, value) {
        final amount = _getDouble(value);

        if (highestCategory == null || amount > highestAmount) {
          highestAmount = amount;
          highestCategory = key.toString();
        }
      });
    }

    final List<String> insights = [];

    if (totalExpense <= 0) {
      insights.add(
        'No expenses have been recorded for this trip yet.',
      );
    } else {
      if (percentage > 100) {
        insights.add(
          'You have exceeded your trip budget by '
          '${_formatCurrency(remainingBudget.abs())}.',
        );
      } else if (percentage >= 80) {
        insights.add(
          'You have used ${percentage.toStringAsFixed(1)}% of your budget. '
          'Consider controlling your remaining spending.',
        );
      } else if (percentage >= 50) {
        insights.add(
          'You have used at least half of your trip budget.',
        );
      } else {
        insights.add(
          'Your spending is currently below half of your trip budget.',
        );
      }

      if (highestCategory != null) {
        insights.add(
          '$highestCategory is your highest spending category '
          'at ${_formatCurrency(highestAmount)}.',
        );
      }

      if (remainingBudget > 0) {
        insights.add(
          'You still have ${_formatCurrency(remainingBudget)} '
          'available from your planned budget.',
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_outlined, size: 23),
              SizedBox(width: 9),
              Text(
                'Spending Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 7,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
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

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 55,
              color: Colors.grey,
            ),
            const SizedBox(height: 15),
            const Text(
              'Could not load expense analysis.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadSummary,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
