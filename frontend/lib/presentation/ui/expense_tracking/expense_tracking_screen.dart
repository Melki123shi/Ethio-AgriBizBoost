// import 'package:app/application/expense_tracking/bloc/expense_tracking_bloc.dart';
// import 'package:app/domain/entity/expense_tracking_entity.dart';
// import 'package:app/presentation/utils/localization_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ExpenseTrackingScreen extends StatefulWidget {
//   const ExpenseTrackingScreen({super.key});

//   @override
//   State<ExpenseTrackingScreen> createState() => _ExpenseTrackingScreenState();
// }

// class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
//   List<Map<String, dynamic>> expenses = [];
//   List<Map<String, dynamic>> assessments = [];

//   bool _isDateAscendingExpense = true;
//   bool _isPriceAscending = true;

//   @override
//   void initState() {
//     super.initState();
//     context.read<ExpenseTrackingBloc>().add(GetExpensesEvent());
//   }

//   Future<void> _showAddExpenseDialog() async {
//   String goods = '';
//   String amount = '';
//   String price = '';
//   DateTime? selectedDate;

//   await showDialog(
//     context: context,
//     builder: (ctx) {
//       final theme = Theme.of(ctx);
//       return AlertDialog(
//         title: Text(context.commonLocals.add_expense),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: theme.primaryColor,
//                 foregroundColor: theme.colorScheme.onPrimary,
//               ),
//               onPressed: () async {
//                 final picked = await showDatePicker(
//                   context: ctx,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                 );
//                 if (picked != null) {
//                   setState(() => selectedDate = picked);
//                 }
//               },
//               child: Text(
//                 selectedDate == null
//                     ? context.commonLocals.pick_date
//                     : '${context.commonLocals.date}: ${selectedDate!.toLocal()}'.split(' ')[0],
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: context.commonLocals.goods,
//                 labelStyle: theme.textTheme.bodyMedium,
//               ),
//               onChanged: (val) => goods = val,
//             ),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: context.commonLocals.amount,
//                 labelStyle: theme.textTheme.bodyMedium,
//               ),
//               onChanged: (val) => amount = val,
//               keyboardType: TextInputType.number,
//             ),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: context.commonLocals.price_etb,
//                 labelStyle: theme.textTheme.bodyMedium,
//               ),
//               onChanged: (val) => price = val,
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             style: TextButton.styleFrom(
//               foregroundColor: theme.primaryColor,
//             ),
//             onPressed: () {
//               if (selectedDate == null) return;

//               final expense = {
//                 'date': selectedDate!.toLocal().toString().split(' ')[0],
//                 'goods': goods,
//                 'amount': amount,
//                 'price': price,
//               };

//               setState(() {
//                 expenses.add(expense);
//               });

//               // Dispatch Bloc event here
//               context.read<ExpenseTrackingBloc>().add(
//                     AddExpenseTrackingEvent(expense as ExpenseTrackingEntity),
//                   );

//               Navigator.pop(ctx);
//             },
//             child: Text(context.commonLocals.add),
//           ),
//         ],
//       );
//     },
//   );
// }

//   void _confirmDelete(bool isExpense, int index) {
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         final theme = Theme.of(ctx);
//         return AlertDialog(
//           title: Text(context.commonLocals.confirm_delete),
//           content: Text(context.commonLocals.delete_entry_prompt),
//           actions: [
//             TextButton(
//               style: TextButton.styleFrom(
//                 foregroundColor: theme.colorScheme.onSurface,
//               ),
//               onPressed: () => Navigator.pop(ctx),
//               child: Text(context.commonLocals.cancel),
//             ),
//             TextButton(
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.red,
//               ),
//               onPressed: () {
//                 setState(() {
//                   if (isExpense) {
//                     expenses.removeAt(index);
//                   } else {
//                     assessments.removeAt(index);
//                   }
//                 });
//                 Navigator.pop(ctx);
//               },
//               child: Text(context.commonLocals.delete),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _confirmEdit() {
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         final theme = Theme.of(ctx);
//         return AlertDialog(
//           title: Text(context.commonLocals.edit_entry),
//           content: Text(context.commonLocals.edit_not_implemented),
//           actions: [
//             TextButton(
//               style: TextButton.styleFrom(
//                 foregroundColor: theme.primaryColor,
//               ),
//               onPressed: () => Navigator.pop(ctx),
//               child: Text(context.commonLocals.ok),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textBody = theme.textTheme.bodyMedium!;
//     final primary = theme.primaryColor;
//     final onSurface = theme.colorScheme.onSurface;
//     final divider = theme.dividerColor;

//     Widget sectionTitle(String title, VoidCallback? onAdd) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.tune, color: primary),
//               const SizedBox(width: 5),
//               Text(title, style: textBody.copyWith(fontSize: 18)),
//             ],
//           ),
//           if (onAdd != null)
//             ElevatedButton(
//               onPressed: onAdd,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primary,
//                 foregroundColor: theme.colorScheme.onPrimary,
//               ),
//               child: Text(context.commonLocals.add),
//             ),
//         ],
//       );
//     }

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
//           child: Column(
//             children: [
//               const Text(
//                 'Expense Tracking',
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 22,),
//               sectionTitle(
//                   context.commonLocals.expense_tracking, _showAddExpenseDialog),
//               const SizedBox(height: 10),
//               BlocBuilder<ExpenseTrackingBloc, ExpenseTrackingState>(
//                 builder: (context, state) {
//                   return SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: DataTable(
//                       headingRowHeight: 60,
//                       dataRowHeight: 60,
//                       horizontalMargin: 8,
//                       columnSpacing: 5,
//                       dividerThickness: 1,
//                       border: TableBorder.all(color: divider),
//                       headingRowColor:
//                           WidgetStateColor.resolveWith((_) => Colors.transparent),
//                       dataRowColor:
//                           WidgetStateColor.resolveWith((_) => Colors.transparent),
//                       headingTextStyle: textBody.copyWith(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 13,
//                         color: onSurface,
//                       ),
//                       dataTextStyle:
//                           textBody.copyWith(color: onSurface, fontSize: 13),
//                       columns: [
//                         DataColumn(
//                           label: SizedBox(
//                             width: 60,
//                             child: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   _isDateAscendingExpense =
//                                       !_isDateAscendingExpense;
//                                   expenses.sort((a, b) {
//                                     final da = DateTime.tryParse(a['date']!) ??
//                                         DateTime(0);
//                                     final db = DateTime.tryParse(b['date']!) ??
//                                         DateTime(0);
//                                     return _isDateAscendingExpense
//                                         ? da.compareTo(db)
//                                         : db.compareTo(da);
//                                   });
//                                 });
//                               },
//                               child: Row(
//                                 children: [
//                                   Flexible(
//                                     child: Text(context.commonLocals.date,
//                                         overflow: TextOverflow.ellipsis),
//                                   ),
//                                   Icon(
//                                     _isDateAscendingExpense
//                                         ? Icons.arrow_upward
//                                         : Icons.arrow_downward,
//                                     size: 13,
//                                     color: onSurface,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 56,
//                             child:
//                                 Center(child: Text(context.commonLocals.goods)),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 52,
//                             child:
//                                 Center(child: Text(context.commonLocals.amount)),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 85,
//                             child: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   _isPriceAscending = !_isPriceAscending;
//                                   expenses.sort((a, b) {
//                                     final pa = double.tryParse(a['price']!) ?? 0;
//                                     final pb = double.tryParse(b['price']!) ?? 0;
//                                     return _isPriceAscending
//                                         ? pa.compareTo(pb)
//                                         : pb.compareTo(pa);
//                                   });
//                                 });
//                               },
//                               child: Row(
//                                 children: [
//                                   Flexible(
//                                       child:
//                                           Text(context.commonLocals.price_etb)),
//                                   Icon(
//                                     _isPriceAscending
//                                         ? Icons.arrow_upward
//                                         : Icons.arrow_downward,
//                                     size: 13,
//                                     color: onSurface,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                             label: SizedBox(
//                                 width: 56,
//                                 child: Center(
//                                     child: Text(context.commonLocals.action)))),
//                       ],
//                       rows: expenses.asMap().entries.map((entry) {
//                         final idx = entry.key;
//                         final item = entry.value;
//                         return DataRow(cells: [
//                           DataCell(Center(
//                               child: Text(item['date'] ?? '',
//                                   overflow: TextOverflow.ellipsis))),
//                           DataCell(Center(child: Text(item['goods'] ?? ''))),
//                           DataCell(Center(child: Text(item['amount'] ?? ''))),
//                           DataCell(Center(child: Text(item['price'] ?? ''))),
//                           DataCell(Center(
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 IconButton(
//                                   icon:
//                                       Icon(Icons.edit, color: primary, size: 20),
//                                   onPressed: _confirmEdit,
//                                   padding: EdgeInsets.zero,
//                                   visualDensity: VisualDensity.compact,
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete,
//                                       color: Colors.red, size: 20),
//                                   onPressed: () => _confirmDelete(true, idx),
//                                   padding: EdgeInsets.zero,
//                                   visualDensity: VisualDensity.compact,
//                                 ),
//                               ],
//                             ),
//                           )),
//                         ]);
//                       }).toList(),
//                     ),
//                   );
//                 },
//               ),

//               // second table code here
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
  @override
  void initState() {
    super.initState();
    // Fetch initial expenses when the screen loads
    context.read<ExpenseTrackingBloc>().add(GetExpensesEvent());
  }

  Future<void> _showAddExpenseDialog() async {
    final formKey = GlobalKey<FormState>();
    String goods = '';
    String amount = '';
    String price = '';
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        // Use StatefulBuilder to manage the state of the dialog independently
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
                            // Use the dialog's own setState
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
                        onChanged: (val) => goods = val,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: context.commonLocals.amount,
                          labelStyle: theme.textTheme.bodyMedium,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          final parsed = int.tryParse(val);
                          if (parsed == null || parsed <= 0)
                            return 'Enter a valid amount';
                          return null;
                        },
                        onChanged: (val) => amount = val,
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: context.commonLocals.price_etb,
                          labelStyle: theme.textTheme.bodyMedium,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          final parsed = double.tryParse(val);
                          if (parsed == null || parsed < 0)
                            return 'Enter valid price';
                          return null;
                        },
                        onChanged: (val) => price = val,
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
                        SnackBar(content: Text(context.commonLocals.pick_date)),
                      );
                      return;
                    }

                    if (formKey.currentState!.validate()) {
                      final expense = ExpenseTrackingEntity.fromUserInput(
                        date: selectedDate!,
                        goods: goods.trim(),
                        amount: int.tryParse(amount) ?? 0,
                        price_etb: double.tryParse(price) ?? 0.0,
                      );
                      context.read<ExpenseTrackingBloc>().add(
                            AddExpenseTrackingEvent(expense),
                          );

                      Navigator.pop(ctx);
                    }
                  },
                  // Corrected button text
                  child: Text(context.commonLocals.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text(context.commonLocals.confirm_delete),
          content: Text(context.commonLocals.delete_entry_prompt),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.commonLocals.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                context
                    .read<ExpenseTrackingBloc>()
                    .add(DeleteExpenseTrackingEvent(id));
                Navigator.pop(ctx);
              },
              child: Text(context.commonLocals.delete),
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
    final onSurface = theme.colorScheme.onSurface;
    final divider = theme.dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracking"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddExpenseDialog,
          )
        ],
      ),
      body: BlocConsumer<ExpenseTrackingBloc, ExpenseTrackingState>(
        // The listener handles side effects like showing SnackBars
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
        // The builder handles building the UI
        builder: (context, state) {
          if (state is GetExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetExpenseFailed) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                IconButton(
                    onPressed: () {
                      context
                          .read<ExpenseTrackingBloc>()
                          .add(GetExpensesEvent());
                    },
                    icon: const Icon(Icons.replay_outlined))
              ],
            );
          } else if (state is GetExpensesSucess) {
            final expenses = state.expenses;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 56,
                dataRowHeight: 56,
                horizontalMargin: 8,
                columnSpacing: 5,
                dividerThickness: 1,
                border: TableBorder.all(color: divider),
                headingTextStyle: textBody.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: onSurface,
                ),
                dataTextStyle:
                    textBody.copyWith(color: onSurface, fontSize: 13),
                columns: [
                  DataColumn(label: Text(context.commonLocals.date)),
                  DataColumn(label: Text(context.commonLocals.goods)),
                  DataColumn(label: Text(context.commonLocals.amount)),
                  DataColumn(label: Text(context.commonLocals.price_etb)),
                  DataColumn(label: Text(context.commonLocals.action)),
                ],
                rows: expenses.map((e) {
                  return DataRow(cells: [
                    DataCell(Text(e.date.toLocal().toString().split(" ")[0])),
                    DataCell(Text(e.goods)),
                    DataCell(Text(e.amount.toString())),
                    DataCell(Text(e.price_etb.toString())),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(e.id ?? ''),
                        )
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            );
          }

          // Show an error message if the initial fetch fails
          if (state is GetExpenseFailed) {
            return Center(child: Text(state.message));
          }

          // Fallback for initial and other states
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}



// const SizedBox(height: 40),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: DataTable(
              //     headingRowHeight: 60,
              //     dataRowHeight: 30,
              //     horizontalMargin: 8,
              //     columnSpacing: 12,
              //     dividerThickness: 1,
              //     border: TableBorder.all(color: divider),
              //     headingRowColor: WidgetStateColor.resolveWith((_) => Colors.transparent),
              //     dataRowColor: WidgetStateColor.resolveWith((_) => Colors.transparent),
              //     headingTextStyle: textBody.copyWith(
              //       fontWeight: FontWeight.bold,
              //       fontSize: 13,
              //       color: onSurface,
              //     ),
              //     dataTextStyle: textBody.copyWith(color: onSurface, fontSize: 12),
              //     columns: [
              //       DataColumn(
              //         label: SizedBox(
              //           width: 60,
              //           child: InkWell(
              //             onTap: () {
              //               setState(() {
              //                 _isDateAscendingAssessment = !_isDateAscendingAssessment;
              //                 assessments.sort((a, b) {
              //                   final da = DateTime.tryParse(a['date']!) ?? DateTime(0);
              //                   final db = DateTime.tryParse(b['date']!) ?? DateTime(0);
              //                   return _isDateAscendingAssessment ? da.compareTo(db) : db.compareTo(da);
              //                 });
              //               });
              //             },
              //             child: Row(
              //               children: [
              //                  Flexible(child: Text(context.commonLocals.date, overflow: TextOverflow.ellipsis)),
              //                 Icon(
              //                   _isDateAscendingAssessment ? Icons.arrow_upward : Icons.arrow_downward,
              //                   size: 10,
              //                   color: onSurface,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //       DataColumn(label: SizedBox(width: 50, child: Center(child: Text(context.commonLocals.goods)))),
              //        DataColumn(label: SizedBox(width: 60, child: Center(child: Text(context.commonLocals.expenses)))),
              //       DataColumn(
              //         label: SizedBox(
              //           width: 50,
              //           child: InkWell(
              //             onTap: () {
              //               setState(() {
              //                 _isProfitAscending = !_isProfitAscending;
              //                 assessments.sort((a, b) {
              //                   final pa = double.tryParse(a['profit']!) ?? 0;
              //                   final pb = double.tryParse(b['profit']!) ?? 0;
              //                   return _isProfitAscending ? pa.compareTo(pb) : pb.compareTo(pa);
              //                 });
              //               });
              //             },
              //             child: Row(
              //               children: [
              //                  Flexible(child: Text(context.commonLocals.profit, overflow: TextOverflow.ellipsis)),
              //                 Icon(
              //                   _isProfitAscending ? Icons.arrow_upward : Icons.arrow_downward,
              //                   size: 10,
              //                   color: onSurface,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //        DataColumn(label: SizedBox(width: 60, child: Center(child: Text(context.commonLocals.stability)))),
              //       DataColumn(label: SizedBox(width: 70, child: Center(child: Text(context.commonLocals.cash_flow)))),
              //       DataColumn(label: SizedBox(width: 60, child: Center(child: Text(context.commonLocals.action)))),
              //     ],
              //     rows: assessments.asMap().entries.map((e) {
              //       final idx = e.key;
              //       final item = e.value;
              //       return DataRow(cells: [
              //         DataCell(Center(child: Text(item['date'] ?? '', overflow: TextOverflow.ellipsis))),
              //         DataCell(Center(child: Text(item['goods'] ?? ''))),
              //         DataCell(Center(child: Text(item['expenses'] ?? ''))),
              //         DataCell(Center(child: Text(item['profit'] ?? ''))),
              //         DataCell(Center(child: Text(item['stability'] ?? ''))),
              //         DataCell(Center(child: Text(item['cashFlow'] ?? ''))),
              //         DataCell(Center(
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               IconButton(
              //                 icon: Icon(Icons.edit, color: primary, size: 16),
              //                 onPressed: _confirmEdit,
              //                 padding: EdgeInsets.zero,
              //                 visualDensity: VisualDensity.compact,
              //               ),
              //               IconButton(
              //                 icon: const Icon(Icons.delete, color: Colors.red, size: 16),
              //                 onPressed: () => _confirmDelete(false, idx),
              //                 padding: EdgeInsets.zero,
              //                 visualDensity: VisualDensity.compact,
              //               ),
              //             ],
              //           ),
              //         )),
              //       ]);
              //     }).toList(),
              //   ),
              // ),