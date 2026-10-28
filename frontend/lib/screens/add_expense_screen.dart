import 'package:flutter/material.dart';

import '../services/expense_api_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final Map<String, dynamic>? expense;

  const AddExpenseScreen({
    super.key,
    required this.trip,
    this.expense,
  });

  bool get isEditing => expense != null;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  String _selectedCategory = 'Food';

  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Stay',
    'Shopping',
    'Activities',
    'Tickets',
    'Other',
  ];

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

  @override
  void initState() {
    super.initState();

    final existingExpense = widget.expense;

    _descriptionController = TextEditingController(
      text: existingExpense?['description']?.toString() ?? '',
    );

    _amountController = TextEditingController(
      text: existingExpense?['amount']?.toString() ?? '',
    );

    _noteController = TextEditingController(
      text: existingExpense?['note']?.toString() ?? '',
    );

    if (existingExpense != null) {
      final existingCategory =
          existingExpense['category']?.toString();

      if (existingCategory != null &&
          _categories.contains(existingCategory)) {
        _selectedCategory = existingCategory;
      } else if (existingCategory != null &&
          existingCategory.trim().isNotEmpty) {
        _categories.add(existingCategory);
        _selectedCategory = existingCategory;
      }

      final existingDate =
          DateTime.tryParse(
            existingExpense['date']?.toString() ?? '',
          );

      if (existingDate != null) {
        _selectedDate = existingDate;
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE EXPENSE
  // ============================================================

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tripId.isEmpty) {
      _showMessage('Trip ID is missing.');
      return;
    }

    final amount =
        double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.isEditing) {
        final expenseId =
            widget.expense?['id']?.toString() ??
            widget.expense?['_id']?.toString() ??
            '';

        if (expenseId.isEmpty) {
          throw Exception('Expense ID is missing.');
        }

        await ExpenseApiService.updateExpense(
          expenseId: expenseId,
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          amount: amount,
          date: _selectedDate,
          note: _cleanNote(),
        );
      } else {
        await ExpenseApiService.createExpense(
          tripId: _tripId,
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          amount: amount,
          date: _selectedDate,
          note: _cleanNote(),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        widget.isEditing
            ? 'Could not update expense. $error'
            : 'Could not add expense. $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _cleanNote() {
    final note = _noteController.text.trim();

    if (note.isEmpty) {
      return null;
    }

    return note;
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = selected;
    });
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
    final title =
        widget.isEditing ? 'Edit Expense' : 'Add Expense';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            children: [
              _buildTripHeader(),

              const SizedBox(height: 20),

              _buildDescriptionField(),

              const SizedBox(height: 16),

              _buildAmountField(),

              const SizedBox(height: 16),

              _buildCategoryField(),

              const SizedBox(height: 16),

              _buildDateField(),

              const SizedBox(height: 16),

              _buildNoteField(),

              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveExpense,
                  child: _isSaving
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isEditing
                              ? 'Update Expense'
                              : 'Save Expense',
                        ),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRIP',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _destination,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
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
  // DESCRIPTION
  // ============================================================

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'e.g. Dinner at restaurant',
        prefixIcon: const Icon(Icons.description_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }

        return null;
      },
    );
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Amount',
        hintText: 'e.g. 850',
        prefixText: '₹ ',
        prefixIcon: const Icon(
          Icons.currency_rupee,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the amount';
        }

        final amount =
            double.tryParse(value.trim());

        if (amount == null) {
          return 'Please enter a valid number';
        }

        if (amount <= 0) {
          return 'Amount must be greater than 0';
        }

        return null;
      },
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(
          Icons.category_outlined,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: _categories.map(
        (category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        },
      ).toList(),
      onChanged: _isSaving
          ? null
          : (value) {
              if (value == null) return;

              setState(() {
                _selectedCategory = value;
              });
            },
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Widget _buildDateField() {
    return InkWell(
      onTap: _isSaving ? null : _selectDate,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          prefixIcon: const Icon(
            Icons.calendar_today_outlined,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          _formatDate(_selectedDate),
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NOTE
  // ============================================================

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Note (Optional)',
        hintText: 'Add any additional information',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 42),
          child: Icon(Icons.notes_outlined),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}