part of 'expense_tracking_bloc.dart';

sealed class ExpenseTrackingEvent {}

class GetExpensesEvent extends ExpenseTrackingEvent {
  List<Object> get props => [];
}

class AddExpenseTrackingEvent extends ExpenseTrackingEvent {
  final ExpenseTrackingEntity expense;

  AddExpenseTrackingEvent(this.expense);

  List<Object> get props => [expense];
}

class UpdateExpenseTrackingEvent extends ExpenseTrackingEvent {
  final String id;
  final ExpenseTrackingEntity expense;

  UpdateExpenseTrackingEvent(this.id, this.expense);

  List<Object> get props => [id, expense];
}

class DeleteExpenseTrackingEvent extends ExpenseTrackingEvent {
  final String id;
  DeleteExpenseTrackingEvent(
    this.id,
  );

  List<Object> get props => [id];
}
