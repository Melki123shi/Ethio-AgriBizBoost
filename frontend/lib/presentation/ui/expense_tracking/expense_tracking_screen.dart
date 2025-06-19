import 'package:app/application/user/user_bloc.dart';
import 'package:app/application/user/user_state.dart';
import 'package:app/domain/entity/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/expense_tracking/bloc/expense_tracking_bloc.dart';
import 'package:app/domain/entity/expense_tracking_entity.dart';
import 'package:app/presentation/utils/localization_extension.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  const ExpenseTrackingScreen({super.key});

  @override
  State<ExpenseTrackingScreen> createState() => _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
  // State for UI sorting direction
  bool _isDateAscending = true;
  bool _isPriceAscending = true;

  @override
  void initState() {
    super.initState();
    // Dispatch event to fetch data from the BLoC
    context.read<ExpenseTrackingBloc>().add(GetExpensesEvent());
  }

  // FUNCTIONALITY from the new version (with Form validation and BLoC integration)
  Future<void> _showAddExpenseDialog() async {
    final formKey = GlobalKey<FormState>();
    String cropType = '';
    String quantitySold = '';
    String totalCost = '';
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context.commonLocals.add_expense),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
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
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: Text(
                          selectedDate == null
                              ? context.commonLocals.pick_date
                              : '${context.commonLocals.date}: ${selectedDate!.toIso8601String().split('T')[0]}',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: context.commonLocals.goods,
                          labelStyle: theme.textTheme.bodyMedium,
                        ),
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Required' : null,
                        onSaved: (val) => cropType = val!,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: context.commonLocals.amount,
                          labelStyle: theme.textTheme.bodyMedium,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (int.tryParse(val) == null ||
                              int.parse(val) <= 0) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (val) => quantitySold = val!,
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: context.commonLocals.price_etb,
                          labelStyle: theme.textTheme.bodyMedium,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (double.tryParse(val) == null ||
                              double.parse(val) < 0) {
                            return 'Enter a valid price';
                          }
                          return null;
                        },
                        onSaved: (val) => totalCost = val!,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.commonLocals.cancel),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                  ),
                  onPressed: () {
                    if (selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(context.commonLocals.pick_date)),
                      );
                      return;
                    }
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      final userState = context.read<UserBloc>().state;

                      if (userState is UserLoaded) {
                        final String? userId = userState.user.userId;

                        if (userId == null) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(const SnackBar(
                              content: Text(
                                  "User ID not found. Please log in again."),
                              backgroundColor: Colors.red,
                            ));
                          Navigator.pop(ctx);
                          return;
                        }

                        final expense = ExpenseTrackingEntity.fromUserInput(
                          userId: userId,
                          date: selectedDate!,
                          cropType: cropType.trim(),
                          quantitySold: int.parse(quantitySold),
                          totalCost: double.parse(totalCost),
                        );

                        context
                            .read<ExpenseTrackingBloc>()
                            .add(AddExpenseTrackingEvent(expense));
                        Navigator.pop(ctx);
                      } else {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                            content: Text(
                                "User data is not available. Please try again."),
                            backgroundColor: Colors.red,
                          ));
                        Navigator.pop(ctx);
                      }
                    }
                  },
                  child: Text(context.commonLocals.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String expenseId) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text(context.commonLocals.confirm_delete),
          content: Text(context.commonLocals.delete_entry_prompt),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.commonLocals.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                context
                    .read<ExpenseTrackingBloc>()
                    .add(DeleteExpenseTrackingEvent(expenseId));
                Navigator.pop(ctx);
              },
              child: Text(context.commonLocals.delete),
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
          title: Text(context.commonLocals.edit_entry),
          content: Text(context.commonLocals.edit_not_implemented),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.primaryColor,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.commonLocals.ok),
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
              child: Text(context.commonLocals.add),
            ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            children: [
              // <<< CHANGE START: Added a Stack for the title and back button >>>
              Stack(
                alignment: Alignment.center,
                children: [
                  // The back button, aligned to the left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back to Profile',
                    ),
                  ),
                  // The centered title
                  const Text(
                    'Expense Tracking',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // <<< CHANGE END >>>
              const SizedBox(height: 22),
              sectionTitle(
                  context.commonLocals.expense_tracking, _showAddExpenseDialog),
              const SizedBox(height: 10),
              BlocConsumer<ExpenseTrackingBloc, ExpenseTrackingState>(
                listener: (context, state) {
                  if (state is ExpenseTrackingAdded) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ));
                  }
                  if (state is GetExpenseFailed) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ));
                  }
                },
                builder: (context, state) {
                  if (state is GetExpenseLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is GetExpensesSucess) {
                    final expenses = state.expenses;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 60,
                        dataRowHeight: 60,
                        border: TableBorder.all(color: divider),
                        headingTextStyle:
                            textBody.copyWith(fontWeight: FontWeight.bold),
                        dataTextStyle: textBody,
                        columns: [
                          DataColumn(
                            label: InkWell(
                              onTap: () {
                                setState(() {
                                  _isDateAscending = !_isDateAscending;
                                  expenses.sort((a, b) => _isDateAscending
                                      ? a.date.compareTo(b.date)
                                      : b.date.compareTo(a.date));
                                });
                              },
                              child: Row(
                                children: [
                                  Text(context.commonLocals.date),
                                  Icon(
                                    _isDateAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(label: Text(context.commonLocals.goods)),
                          DataColumn(label: Text(context.commonLocals.amount)),
                          DataColumn(
                            label: InkWell(
                              onTap: () {
                                setState(() {
                                  _isPriceAscending = !_isPriceAscending;
                                  expenses.sort((a, b) => _isPriceAscending
                                      ? a.totalCost.compareTo(b.totalCost)
                                      : b.totalCost.compareTo(a.totalCost));
                                });
                              },
                              child: Row(
                                children: [
                                  Text(context.commonLocals.price_etb),
                                  Icon(
                                    _isPriceAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(
                              label: Center(
                                  child: Text(context.commonLocals.action))),
                        ],
                        rows: expenses.map((expense) {
                          return DataRow(cells: [
                            DataCell(Text(expense.date
                                .toLocal()
                                .toString()
                                .split(" ")[0])),
                            DataCell(Text(expense.cropType)),
                            DataCell(Text(expense.quantitySold.toString())),
                            DataCell(Text(expense.totalCost.toString())),
                            DataCell(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: primary, size: 20),
                                    onPressed: _confirmEdit,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 20),
                                    onPressed: () =>
                                        _confirmDelete(expense.id ?? ''),
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    );
                  }
                  if (state is GetExpenseFailed) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          IconButton(
                            onPressed: () => context
                                .read<ExpenseTrackingBloc>()
                                .add(GetExpensesEvent()),
                            icon: const Icon(Icons.replay_outlined),
                          )
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text("Something Went Wrong Try again"));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}