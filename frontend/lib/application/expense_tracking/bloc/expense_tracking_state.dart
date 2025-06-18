part of 'expense_tracking_bloc.dart';

sealed class ExpenseTrackingState {}

final class ExpenseTrackingInitial extends ExpenseTrackingState {}

class GetExpenseLoading extends ExpenseTrackingState {}

class GetExpensesSucess extends ExpenseTrackingState {
  final List<ExpenseTrackingEntity> expenses;

  GetExpensesSucess(this.expenses);
  List<Object> get props => [expenses];
}
class GetExpenseFailed extends ExpenseTrackingState {
  final String message;

  GetExpenseFailed(this.message);
  List<Object> get props => [message];

}

class ExpenseTrackingAdded extends ExpenseTrackingState {
  final String message;

  ExpenseTrackingAdded(this.message);
  List<Object> get props => [message];

  add(AddExpenseTrackingEvent addExpenseTrackingEvent) {}
  
}
