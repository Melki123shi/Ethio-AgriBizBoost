import 'package:app/domain/entity/expense_tracking_entity.dart';

class ExpenseTrackingDTO {
  final DateTime date;
  final String goods;
  final int amount;
  final double price_etb;

  ExpenseTrackingDTO({
      required this.date,
      required this.goods,
      required this.amount,
      required this.price_etb,
  });

  /// JSON → DTO
  factory ExpenseTrackingDTO.fromJson(Map<String, dynamic> json) {
    return ExpenseTrackingDTO(
      date: DateTime.parse(json['date'] as String),
      goods: json['goods'] as String,
      amount: json['amount'] is int
          ? json['amount'] as int
          : int.tryParse(json['amount'].toString()) ?? 0,
      price_etb: (json['price_etb'] as num).toDouble(),
    );
  }

  /// DTO → JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'goods': goods,
      'amount': amount,
      'price_etb': price_etb,
    };
  }

  /// Entity → DTO
  static ExpenseTrackingDTO fromEntity(ExpenseTrackingEntity e) {
    return ExpenseTrackingDTO(
      date: e.date,
      goods: e.goods,
      amount: e.amount,
      price_etb: e.price_etb,
    );
  }

  /// DTO → Entity
  ExpenseTrackingEntity toEntity() {
    return ExpenseTrackingEntity(
      date: date,
      goods: goods,
      amount: amount,
      price_etb: price_etb,
    );
  }
}
