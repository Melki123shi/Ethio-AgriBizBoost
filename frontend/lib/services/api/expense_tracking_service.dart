import 'package:app/domain/entity/expense_tracking_entity.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:dio/dio.dart';

class ExpenseTrackingService {
  final Dio dio = DioClient.getDio();

  Future<void> createExpense(ExpenseTrackingEntity expense) async {
    try {
      final response = await dio.post(
        "/expenses",
        data: expense.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to add expense: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("Failed to add expense: ${e.message}");
    } catch (e) {
      throw Exception("An unexpected error occurred while adding expense");
    }
  }

  Future<List<ExpenseTrackingEntity>> getExpenses() async {
    try {
      final response = await dio.get("/expenses");

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        return data
            .map((e) => ExpenseTrackingEntity.fromJson(e))
            .toList();
      } else {
        throw Exception("Unexpected response format: ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Failed to fetch expenses: ${e.message}");
    } catch (e) {
      throw Exception("An unexpected error occurred while fetching expenses");
    }
  }

  Future<void> updateExpense(String id, ExpenseTrackingEntity updated) async {
    try {
      final response = await dio.put(
        "/expenses/$id",
        data: updated.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update expense: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("Failed to update expense: ${e.message}");
    } catch (e) {
      throw Exception("An unexpected error occurred while updating expense");
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final response = await dio.delete("/expenses/$id");

      if (response.statusCode != 200) {
        throw Exception("Failed to delete expense: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("Failed to delete expense: ${e.message}");
    } catch (e) {
      throw Exception("An unexpected error occurred while deleting expense");
    }
  }
}
