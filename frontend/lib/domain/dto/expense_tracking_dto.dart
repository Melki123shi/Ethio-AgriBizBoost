import 'package:app/domain/entity/expense_tracking_entity.dart';

class ExpenseTrackingDTO {
  final DateTime date;
  final String cropType;
  final int quantitySold;
  final double totalCost;
  final String userId;

  ExpenseTrackingDTO({
      required this.date,
      required this.cropType,
      required this.quantitySold,
      required this.totalCost,
      required this.userId,
  });

  /// JSON → DTO
  factory ExpenseTrackingDTO.fromJson(Map<String, dynamic> json) {
    return ExpenseTrackingDTO(
      date: DateTime.parse(json['date'] as String),
      cropType: json['cropType'] as String,
      quantitySold: json['quantitySold'] is int
          ? json['quantitySold'] as int
          : int.tryParse(json['quantitySold'].toString()) ?? 0,
      totalCost: (json['totalCost'] as num).toDouble(),
      userId: json['userId'],
    );
  }

  /// DTO → JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'cropType': cropType,
      'quantitySold': quantitySold,
      'totalCost': totalCost,
      'userId': userId, 
    };
  }

  /// Entity → DTO
  static ExpenseTrackingDTO fromEntity(ExpenseTrackingEntity e) {
    return ExpenseTrackingDTO(
      date: e.date,
      cropType: e.cropType,
      quantitySold: e.quantitySold,
      totalCost: e.totalCost,
      userId: e.userId,
    );
  }

  /// DTO → Entity
  ExpenseTrackingEntity toEntity() {
    return ExpenseTrackingEntity(
      date: date,
      cropType: cropType,
      quantitySold: quantitySold,
      totalCost: totalCost,
      userId: userId,
    );
  }
}
