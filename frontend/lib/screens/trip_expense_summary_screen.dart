import 'package:flutter/material.dart';

import '../services/expense_api_service.dart';

class TripExpenseSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> trip;

  const TripExpenseSummaryScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripExpenseSummaryScreen> createState() =>
      _TripExpenseSummaryScreenState();
}

class _TripExpenseSummaryScreenState
    extends State<TripExpenseSummaryScreen> {
  Map<String, dynamic>? _summary;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  // ============================================================
  // LOAD SUMMARY
  // ============================================================

  Future<void> _loadSummary() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final tripId =
        widget.trip['id']?.toString() ??
        widget.trip['_id']?.toString() ??
        widget.trip['trip_id']?.toString() ??
        '';

    if (tripId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Trip ID is missing.';
      });

      return;
    }

    try {
      final summary =
          await ExpenseApiService.getExpenseSummary(tripId);

      if (!mounted) return;

      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _number(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  String _currency(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  double get _budget {
    return _number(
      _summary?['budget'] ??
          _summary?['trip_budget'] ??
          widget.trip['budget'],
    );
  }

  double get _totalExpense {
    return _number(
      _summary?['total_expense'],
    );
  }

  double get _remainingBudget {
    return _number(
      _summary?['remaining_budget'],
    );
  }

  double get _budgetUsedPercentage {
    final value = _number(
      _summary?['budget_used_percentage'],
    );

    return value.clamp(0.0, 100.0);
  }

  int get _expenseCount {
    final value =
        _summary?['expense_count'];

    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  Map<String, dynamic> get _categoryTotals {
    final categories =
        _summary?['category_totals'];

    if (categories is Map) {
      return Map<String, dynamic>.from(
        categories,
      );
    }

    return {};
  }

  String get _budgetStatus {
    if (_budget <= 0) {
      return 'No budget set';
    }

    if (_totalExpense > _budget) {
      return 'Over Budget';
    }

    if (_budgetUsedPercentage >= 80) {
      return 'Near Budget';
    }

    return 'Within Budget';
  }

  IconData get _budgetStatusIcon {
    if (_budgetStatus == 'Over Budget') {
      return Icons.warning_amber_rounded;
    }

    if (_budgetStatus == 'Near Budget') {
      return Icons.info_outline;
    }

    return Icons.check_circle_outline;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final destination =
        widget.trip['location']?.toString() ??
            widget.trip['destination']?.toString() ??
            'Trip';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Expense Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _isLoading ? null : _loadSummary,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 14),
                  Text(
                    'Analyzing your expenses...',
                  ),
                ],
              ),
            )
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadSummary,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      30,
                    ),
                    children: [
                      _buildTripHeader(
                        destination,
                      ),

                      const SizedBox(height: 18),

                      _buildOverviewCard(),

                      const SizedBox(height: 16),

                      _buildBudgetProgress(),

                      const SizedBox(height: 16),

                      _buildStatusCard(),

                      const SizedBox(height: 24),

                      const Text(
                        'Expense Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildCategoryBreakdown(),

                      const SizedBox(height: 24),

                      _buildAnalysisCard(),
                    ],
                  ),
                ),
    );
  }

  // ============================================================
  // TRIP HEADER
  // ============================================================

  Widget _buildTripHeader(
    String destination,
  ) {
    final startDate =
        widget.trip['start_date']
            ?.toString();

    final endDate =
        widget.trip['end_date']
            ?.toString();

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'TRIP EXPENSE ANALYSIS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            destination,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          if (startDate != null ||
              endDate != null) ...[
            const SizedBox(height: 8),
            Text(
              '${startDate ?? ''}'
              '${startDate != null && endDate != null ? '  →  ' : ''}'
              '${endDate ?? ''}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW CARD
  // ============================================================

  Widget _buildOverviewCard() {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _summaryValue(
                  icon:
                      Icons.account_balance_wallet_outlined,
                  title: 'Budget',
                  value:
                      _currency(_budget),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryValue(
                  icon:
                      Icons.payments_outlined,
                  title: 'Spent',
                  value:
                      _currency(_totalExpense),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _summaryValue(
                  icon:
                      Icons.savings_outlined,
                  title: 'Remaining',
                  value:
                      _currency(_remainingBudget),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryValue(
                  icon:
                      Icons.receipt_long_outlined,
                  title: 'Expenses',
                  value:
                      '$_expenseCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY VALUE
  // ============================================================

  Widget _summaryValue({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUDGET PROGRESS
  // ============================================================

  Widget _buildBudgetProgress() {
    final progress =
        (_budgetUsedPercentage / 100)
            .clamp(0.0, 1.0);

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget Used',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              Text(
                '${_budgetUsedPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child:
                LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor:
                  Colors.grey.shade200,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '${_currency(_totalExpense)} spent out of '
            '${_currency(_budget)}',
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
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard() {
    final isOverBudget =
        _budgetStatus == 'Over Budget';

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isOverBudget
            ? Colors.red.shade50
            : Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _budgetStatusIcon,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budget Status',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _budgetStatus,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
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
    if (_categoryTotals.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              'No expense categories yet.',
              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Add expenses to see the breakdown.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final entries =
        _categoryTotals.entries.toList();

    entries.sort(
      (a, b) => _number(b.value)
          .compareTo(
        _number(a.value),
      ),
    );

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          ...entries.map(
            (entry) {
              final amount =
                  _number(entry.value);

              final percentage =
                  _totalExpense > 0
                      ? (amount /
                              _totalExpense) *
                          100
                      : 0.0;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 18,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatCategory(
                              entry.key,
                            ),
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _currency(amount),
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child:
                              ClipRRect(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                            child:
                                LinearProgressIndicator(
                              value:
                                  (percentage /
                                          100)
                                      .clamp(
                                0.0,
                                1.0,
                              ),
                              minHeight: 8,
                              backgroundColor:
                                  Colors.grey
                                      .shade200,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 45,
                          child: Text(
                            '${percentage.toStringAsFixed(0)}%',
                            textAlign:
                                TextAlign.right,
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                              fontSize:
                                  12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY NAME
  // ============================================================

  String _formatCategory(
    String category,
  ) {
    if (category.isEmpty) {
      return 'Other';
    }

    return category[0].toUpperCase() +
        category.substring(1);
  }

  // ============================================================
  // ANALYSIS
  // ============================================================

  Widget _buildAnalysisCard() {
    String message;

    if (_totalExpense == 0) {
      message =
          'No expenses have been recorded for this trip yet.';
    } else if (_totalExpense > _budget &&
        _budget > 0) {
      final overspent =
          _totalExpense - _budget;

      message =
          'You have exceeded your trip budget by '
          '${_currency(overspent)}. Consider reducing '
          'spending in the highest expense categories.';
    } else if (_budgetUsedPercentage >=
        80) {
      message =
          'You have already used '
          '${_budgetUsedPercentage.toStringAsFixed(0)}% '
          'of your trip budget. Keep track of your remaining '
          'expenses carefully.';
    } else {
      message =
          'Your spending is currently within the planned '
          'trip budget. You have '
          '${_currency(_remainingBudget)} remaining.';
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics_outlined,
              ),
              SizedBox(width: 8),
              Text(
                'Expense Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            message,
            style: const TextStyle(
              height: 1.5,
              color: Colors.black87,
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
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 55,
              color: Colors.grey,
            ),

            const SizedBox(height: 15),

            const Text(
              'Could not load expense analysis.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _error ?? 'Unknown error',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _loadSummary,
              icon: const Icon(
                Icons.refresh,
              ),
              label:
                  const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}