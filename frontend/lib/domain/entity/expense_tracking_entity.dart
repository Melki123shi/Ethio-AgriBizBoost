class ExpenseTrackingEntity {
  final String? id;
  final DateTime date;
  final String cropType;
  final int quantitySold;
  final double totalCost;
  final String userId; // <-- Add this field

  ExpenseTrackingEntity({
    this.id,
    required this.date,
    required this.cropType,
    required this.quantitySold,
    required this.totalCost,
    required this.userId, // <-- Add to constructor
  });

  static ExpenseTrackingEntity fromUserInput({
    required String userId,
    required DateTime date,
    required String cropType,
    required int quantitySold,
    required double totalCost,
  }) {
    return ExpenseTrackingEntity(
      userId: userId,
      date: date,
      cropType: cropType,
      quantitySold: quantitySold,
      totalCost: totalCost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String(),
      'cropType': cropType,
      'quantitySold': quantitySold,
      'totalCost': totalCost,
    };
  }

  factory ExpenseTrackingEntity.fromJson(Map<String, dynamic> json) {
    return ExpenseTrackingEntity(
      id: json['_id'], 
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      cropType: json['cropType'],
      quantitySold: (json['quantitySold'] as num).toInt(),
      totalCost: (json['totalCost'] is int)
          ? (json['totalCost'] as int).toDouble()
          : json['totalCost'].toDouble(),
    );
  }
}

