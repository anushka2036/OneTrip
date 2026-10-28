import 'package:flutter/material.dart';

import '../services/expense_api_service.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  final Map<String, dynamic> trip;

  const ExpensesScreen({
    super.key,
    required this.trip,
  });

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Map<String, dynamic>> _expenses = [];

  Map<String, dynamic>? _summary;

  bool _isLoading = true;
  bool _isLoadingSummary = true;

  String? _error;

  final Set<String> _deletingExpenseIds = {};

  String get _tripId {
    return widget.trip['id']?.toString() ??
        widget.trip['_id']?.toString() ??
        widget.trip['trip_id']?.toString() ??
        '';
  }

  String get _destination {
    return widget.trip['location']?.toString() ??
        widget.trip['destination']?.toString() ??
        'Trip';
  }

  double get _budget {
    return (widget.trip['budget'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _loadExpenseData();
  }

  // ============================================================
  // LOAD EXPENSES + SUMMARY
  // ============================================================

  Future<void> _loadExpenseData() async {
    if (!mounted) return;

    if (_tripId.isEmpty) {
      setState(() {
        _isLoading = false;
        _isLoadingSummary = false;
        _error = 'Trip ID is missing.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isLoadingSummary = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ExpenseApiService.getExpenses(_tripId),
        ExpenseApiService.getExpenseSummary(_tripId),
      ]);

      if (!mounted) return;

      final expenses =
          results[0] as List<Map<String, dynamic>>;

      final summary =
          results[1] as Map<String, dynamic>;

      setState(() {
        _expenses = expenses;
        _summary = summary;
        _isLoading = false;
        _isLoadingSummary = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isLoadingSummary = false;
        _error = error.toString();
      });
    }
  }

  // ============================================================
  // ADD EXPENSE
  // ============================================================

  Future<void> _addExpense() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          trip: widget.trip,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadExpenseData();

      if (!mounted) return;

      _showMessage('Expense added successfully.');
    }
  }

  // ============================================================
  // EDIT EXPENSE
  // ============================================================

  Future<void> _editExpense(
    Map<String, dynamic> expense,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          trip: widget.trip,
          expense: expense,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadExpenseData();

      if (!mounted) return;

      _showMessage('Expense updated successfully.');
    }
  }

  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  Future<void> _confirmDeleteExpense(
    Map<String, dynamic> expense,
  ) async {
    final expenseId =
        expense['id']?.toString() ??
        expense['_id']?.toString() ??
        '';

    if (expenseId.isEmpty) {
      _showMessage('Cannot delete this expense: ID is missing.');
      return;
    }

    if (_deletingExpenseIds.contains(expenseId)) {
      return;
    }

    final description =
        expense['description']?.toString() ?? 'this expense';

    final amount =
        (expense['amount'] as num?)?.toDouble() ?? 0.0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Expense?'),
          content: Text(
            'Are you sure you want to delete "$description" '
            'of ₹${amount.toStringAsFixed(2)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deletingExpenseIds.add(expenseId);
    });

    try {
      await ExpenseApiService.deleteExpense(expenseId);

      if (!mounted) return;

      setState(() {
        _expenses.removeWhere((item) {
          final itemId =
              item['id']?.toString() ??
              item['_id']?.toString() ??
              '';

          return itemId == expenseId;
        });
      });

      await _loadExpenseData();

      if (!mounted) return;

      _showMessage('Expense deleted successfully.');
    } catch (error) {
      if (!mounted) return;

      _showMessage('Could not delete expense. $error');
    } finally {
      if (mounted) {
        setState(() {
          _deletingExpenseIds.remove(expenseId);
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Expense Tracking'),
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadExpenseData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _buildTripHeader(),
            const SizedBox(height: 16),
            _buildSummaryCard(),
            const SizedBox(height: 20),
            _buildExpensesSection(),
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
            'EXPENSES FOR',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _destination,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Budget: ₹${_budget.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard() {
    if (_isLoadingSummary) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Calculating expenses...'),
          ],
        ),
      );
    }

    final budget =
        (_summary?['budget'] as num?)?.toDouble() ?? _budget;

    final totalExpense =
        (_summary?['total_expense'] as num?)?.toDouble() ?? 0.0;

    final remainingBudget =
        (_summary?['remaining_budget'] as num?)?.toDouble() ??
            (budget - totalExpense);

    final percentage =
        (_summary?['budget_used_percentage'] as num?)?.toDouble() ??
            0.0;

    final displayPercentage =
        percentage.clamp(0.0, 100.0).toDouble();

    final isOverBudget = remainingBudget < 0;

    final categoryTotals =
        _summary?['category_totals'] is Map
            ? Map<String, dynamic>.from(
                _summary!['category_totals'],
              )
            : <String, dynamic>{};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  title: 'Budget',
                  value: '₹${budget.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  title: 'Spent',
                  value: '₹${totalExpense.toStringAsFixed(0)}',
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  title: isOverBudget ? 'Over Budget' : 'Remaining',
                  value:
                      '₹${remainingBudget.abs().toStringAsFixed(0)}',
                  icon: isOverBudget
                      ? Icons.warning_amber_outlined
                      : Icons.savings_outlined,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  title: 'Used',
                  value: '${percentage.toStringAsFixed(1)}%',
                  icon: Icons.pie_chart_outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: displayPercentage / 100,
              minHeight: 9,
              backgroundColor: Colors.grey.shade200,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isOverBudget
                ? 'You have exceeded your planned budget.'
                : '${percentage.toStringAsFixed(1)}% of your budget has been used.',
            style: TextStyle(
              color: isOverBudget
                  ? Colors.red
                  : Colors.grey.shade700,
              fontSize: 12,
              fontWeight: isOverBudget
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),

          if (categoryTotals.isNotEmpty) ...[
            const SizedBox(height: 22),

            const Text(
              'Spending by Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...categoryTotals.entries.map(
              (entry) {
                final amount =
                    (entry.value as num?)?.toDouble() ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '₹${amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EXPENSES SECTION
  // ============================================================

  Widget _buildExpensesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expenses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        if (_error != null && _expenses.isEmpty)
          _buildError()
        else if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_expenses.isEmpty)
          _buildEmptyExpenses()
        else
          ..._expenses.map(_expenseCard),
      ],
    );
  }

  // ============================================================
  // EXPENSE CARD
  // ============================================================

  Widget _expenseCard(Map<String, dynamic> expense) {
    final expenseId =
        expense['id']?.toString() ??
        expense['_id']?.toString() ??
        '';

    final category =
        expense['category']?.toString() ?? 'Other';

    final description =
        expense['description']?.toString() ?? 'Expense';

    final note =
        expense['note']?.toString();

    final amount =
        (expense['amount'] as num?)?.toDouble() ?? 0.0;

    final date =
        expense['date']?.toString() ?? '';

    final isDeleting =
        _deletingExpenseIds.contains(expenseId);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(category),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDisplayDate(date),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              if (note != null && note.trim().isNotEmpty) ...[
                const SizedBox(width: 15),
                const Icon(
                  Icons.notes_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ] else
                const Spacer(),

              IconButton(
                tooltip: 'Edit expense',
                onPressed: isDeleting
                    ? null
                    : () => _editExpense(expense),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                ),
              ),

              IconButton(
                tooltip: 'Delete expense',
                onPressed: isDeleting
                    ? null
                    : () => _confirmDeleteExpense(expense),
                icon: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyExpenses() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 52,
            color: Colors.grey,
          ),
          const SizedBox(height: 14),
          const Text(
            'No expenses added yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Start tracking your spending for this trip.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addExpense,
            icon: const Icon(Icons.add),
            label: const Text('Add First Expense'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 45,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load expenses.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _loadExpenseData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Icons.directions_car_outlined;

      case 'food':
        return Icons.restaurant_outlined;

      case 'stay':
      case 'hotel':
      case 'accommodation':
        return Icons.hotel_outlined;

      case 'shopping':
        return Icons.shopping_bag_outlined;

      case 'activities':
      case 'activity':
      case 'entertainment':
        return Icons.local_activity_outlined;

      case 'tickets':
        return Icons.confirmation_number_outlined;

      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDisplayDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}