import 'package:app/services/api/expense_tracking_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/domain/entity/expense_tracking_entity.dart';

part 'expense_tracking_event.dart';
part 'expense_tracking_state.dart';

class ExpenseTrackingBloc extends Bloc<ExpenseTrackingEvent, ExpenseTrackingState> {
  final ExpenseTrackingService expenseTrackingService;

  ExpenseTrackingBloc(this.expenseTrackingService) : super(ExpenseTrackingInitial()) {
    on<GetExpensesEvent>(_onGetExpenses);
    on<AddExpenseTrackingEvent>(_onAddExpense);
    on<UpdateExpenseTrackingEvent>(_onUpdateExpense);
    on<DeleteExpenseTrackingEvent>(_onDeleteExpense);
  }

  Future<void> _onGetExpenses(
    GetExpensesEvent event,
    Emitter<ExpenseTrackingState> emit,
  ) async {
    emit(GetExpenseLoading());
    try {
      final expenses = await expenseTrackingService.getExpenses();
      emit(GetExpensesSucess(expenses));
    } catch (e) {
      emit(GetExpenseFailed(e.toString()));
    }
  }

  Future<void> _onAddExpense(
    AddExpenseTrackingEvent event,
    Emitter<ExpenseTrackingState> emit,
  ) async {
    try {
      await expenseTrackingService.createExpense(event.expense);
      add(GetExpensesEvent());
      emit(ExpenseTrackingAdded("Expense added successfully"));
    } catch (e) {
      emit(GetExpenseFailed(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseTrackingEvent event,
    Emitter<ExpenseTrackingState> emit,
  ) async {
    try {
      await expenseTrackingService.updateExpense(event.id, event.expense);
      add(GetExpensesEvent());
      emit(ExpenseTrackingAdded("Expense updated successfully"));
    } catch (e) {
      emit(GetExpenseFailed(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseTrackingEvent event,
    Emitter<ExpenseTrackingState> emit,
  ) async {
    try {
      await expenseTrackingService.deleteExpense(event.id);
      add(GetExpensesEvent());
      emit(ExpenseTrackingAdded("Expense deleted successfully"));
    } catch (e) {
      emit(GetExpenseFailed(e.toString()));
    }
  }
}

