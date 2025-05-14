import 'package:flutter/material.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  const ExpenseTrackingScreen({super.key});

  @override
  State<ExpenseTrackingScreen> createState() => _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> assessments = [];

  bool _isDateAscendingExpense = true;
  bool _isPriceAscending = true;
  bool _isDateAscendingAssessment = true;
  bool _isProfitAscending = true;

  Future<void> _showAddExpenseDialog() async {
    String goods = '';
    String amount = '';
    String price = '';
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Text(
                  selectedDate == null
                      ? 'Pick Date'
                      : 'Date: ${selectedDate!.toLocal()}'.split(' ')[0],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Goods',
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                onChanged: (val) => goods = val,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                onChanged: (val) => amount = val,
                keyboardType: TextInputType.number,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Price (ETB)',
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                onChanged: (val) => price = val,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.primaryColor,
              ),
              onPressed: () {
                if (selectedDate == null) return;
                setState(() {
                  expenses.add({
                    'date': selectedDate!.toLocal().toString().split(' ')[0],
                    'goods': goods,
                    'amount': amount,
                    'price': price,
                  });
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddAssessmentDialog() async {
    String goods = '';
    String expensesStr = '';
    String profit = '';
    String stability = '';
    String cashFlow = '';
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: const Text('Add Assessment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Text(
                  selectedDate == null
                      ? 'Pick Date'
                      : 'Date: ${selectedDate!.toLocal()}'.split(' ')[0],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Goods',
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                onChanged: (val) => goods = val,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Expenses',
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                onChanged: (val) => expensesStr = val,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Profit',
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                onChanged: (val) => profit = val,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Stability',
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                onChanged: (val) => stability = val,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Cash Flow',
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                onChanged: (val) => cashFlow = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.primaryColor,
              ),
              onPressed: () {
                if (selectedDate == null) return;
                setState(() {
                  assessments.add({
                    'date': selectedDate!.toLocal().toString().split(' ')[0],
                    'goods': goods,
                    'expenses': expensesStr,
                    'profit': profit,
                    'stability': stability,
                    'cashFlow': cashFlow,
                  });
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(bool isExpense, int index) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  if (isExpense) {
                    expenses.removeAt(index);
                  } else {
                    assessments.removeAt(index);
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _confirmEdit() {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: const Text('Edit Entry'),
          content: const Text('Editing is not yet implemented.'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.primaryColor,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textBody = theme.textTheme.bodyMedium!;
    final primary = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;
    final divider = theme.dividerColor;

    Widget sectionTitle(String title, VoidCallback? onAdd) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: primary),
              const SizedBox(width: 5),
              Text(title, style: textBody.copyWith(fontSize: 18)),
            ],
          ),
          if (onAdd != null)
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Add'),
            ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          children: [
            sectionTitle('Expense Tracking', _showAddExpenseDialog),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 60,
                dataRowHeight: 60,
                horizontalMargin: 8,
                columnSpacing: 5,
                dividerThickness: 1,
                border: TableBorder.all(color: divider),
                headingRowColor: WidgetStateColor.resolveWith((_) => Colors.transparent),
                dataRowColor: WidgetStateColor.resolveWith((_) => Colors.transparent),
                headingTextStyle: textBody.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: onSurface,
                ),
                dataTextStyle: textBody.copyWith(color: onSurface, fontSize: 13),
                columns: [
                  DataColumn(
                    label: SizedBox(
                      width: 60,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isDateAscendingExpense = !_isDateAscendingExpense;
                            expenses.sort((a, b) {
                              final da = DateTime.tryParse(a['date']!) ?? DateTime(0);
                              final db = DateTime.tryParse(b['date']!) ?? DateTime(0);
                              return _isDateAscendingExpense ? da.compareTo(db) : db.compareTo(da);
                            });
                          });
                        },
                        child: Row(
                          children: [
                            const Flexible(
                              child: Text('Date', overflow: TextOverflow.ellipsis),
                            ),
                            Icon(
                              _isDateAscendingExpense ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 13,
                              color: onSurface,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const DataColumn(
                    label: SizedBox(
                      width: 56,
                      child: Center(child: Text('Goods')),
                    ),
                  ),
                  const DataColumn(
                    label: SizedBox(
                      width: 52,
                      child: Center(child: Text('Amount')),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 85,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isPriceAscending = !_isPriceAscending;
                            expenses.sort((a, b) {
                              final pa = double.tryParse(a['price']!) ?? 0;
                              final pb = double.tryParse(b['price']!) ?? 0;
                              return _isPriceAscending ? pa.compareTo(pb) : pb.compareTo(pa);
                            });
                          });
                        },
                        child: Row(
                          children: [
                            const Flexible(child: Text('Price (ETB)')),
                            Icon(
                              _isPriceAscending ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 13,
                              color: onSurface,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const DataColumn(label: SizedBox(width: 56, child: Center(child: Text('Action')))),
                ],
                rows: expenses.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return DataRow(cells: [
                    DataCell(Center(child: Text(item['date'] ?? '', overflow: TextOverflow.ellipsis))),
                    DataCell(Center(child: Text(item['goods'] ?? ''))),
                    DataCell(Center(child: Text(item['amount'] ?? ''))),
                    DataCell(Center(child: Text(item['price'] ?? ''))),
                    DataCell(Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: primary, size: 20),
                            onPressed: _confirmEdit,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _confirmDelete(true, idx),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),
            sectionTitle('Assessment History', _showAddAssessmentDialog),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 60,
                dataRowHeight: 30,
                horizontalMargin: 8,
                columnSpacing: 12,
                dividerThickness: 1,
                border: TableBorder.all(color: divider),
                headingRowColor: WidgetStateColor.resolveWith((_) => Colors.transparent),
                dataRowColor: WidgetStateColor.resolveWith((_) => Colors.transparent),
                headingTextStyle: textBody.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: onSurface,
                ),
                dataTextStyle: textBody.copyWith(color: onSurface, fontSize: 12),
                columns: [
                  DataColumn(
                    label: SizedBox(
                      width: 60,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isDateAscendingAssessment = !_isDateAscendingAssessment;
                            assessments.sort((a, b) {
                              final da = DateTime.tryParse(a['date']!) ?? DateTime(0);
                              final db = DateTime.tryParse(b['date']!) ?? DateTime(0);
                              return _isDateAscendingAssessment ? da.compareTo(db) : db.compareTo(da);
                            });
                          });
                        },
                        child: Row(
                          children: [
                            const Flexible(child: Text('Date', overflow: TextOverflow.ellipsis)),
                            Icon(
                              _isDateAscendingAssessment ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 10,
                              color: onSurface,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const DataColumn(label: SizedBox(width: 50, child: Center(child: Text('Goods')))),
                  const DataColumn(label: SizedBox(width: 60, child: Center(child: Text('Expenses')))),
                  DataColumn(
                    label: SizedBox(
                      width: 50,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isProfitAscending = !_isProfitAscending;
                            assessments.sort((a, b) {
                              final pa = double.tryParse(a['profit']!) ?? 0;
                              final pb = double.tryParse(b['profit']!) ?? 0;
                              return _isProfitAscending ? pa.compareTo(pb) : pb.compareTo(pa);
                            });
                          });
                        },
                        child: Row(
                          children: [
                            const Flexible(child: Text('Profit', overflow: TextOverflow.ellipsis)),
                            Icon(
                              _isProfitAscending ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 10,
                              color: onSurface,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const DataColumn(label: SizedBox(width: 60, child: Center(child: Text('Stability')))),
                  const DataColumn(label: SizedBox(width: 70, child: Center(child: Text('Cash Flow')))),
                  const DataColumn(label: SizedBox(width: 60, child: Center(child: Text('Action')))),
                ],
                rows: assessments.asMap().entries.map((e) {
                  final idx = e.key;
                  final item = e.value;
                  return DataRow(cells: [
                    DataCell(Center(child: Text(item['date'] ?? '', overflow: TextOverflow.ellipsis))),
                    DataCell(Center(child: Text(item['goods'] ?? ''))),
                    DataCell(Center(child: Text(item['expenses'] ?? ''))),
                    DataCell(Center(child: Text(item['profit'] ?? ''))),
                    DataCell(Center(child: Text(item['stability'] ?? ''))),
                    DataCell(Center(child: Text(item['cashFlow'] ?? ''))),
                    DataCell(Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: primary, size: 16),
                            onPressed: _confirmEdit,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                            onPressed: () => _confirmDelete(false, idx),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
