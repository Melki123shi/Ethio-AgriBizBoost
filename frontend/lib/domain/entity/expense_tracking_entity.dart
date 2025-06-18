// class ExpenseTrackingEntity {
//   final DateTime date;
//   final String goods;
//   final int amount;
//   final double price_etb;

//   ExpenseTrackingEntity({
//     required this.date,
//     required this.goods,
//     required this.amount,
//     required this.price_etb,
//   });

//   static ExpenseTrackingEntity fromUserInput({
//     required DateTime date,
//     required String goods,
//     required int amount,
//     required double price_etb,
//   }) {
//     return ExpenseTrackingEntity(
//       date: date,
//       goods: goods,
//       amount: amount,
//       price_etb: price_etb,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'date': date,
//       'goods': goods,
//       'amount': amount,
//       'price_etb': price_etb,
//     };
//   }
// }


class ExpenseTrackingEntity {
  final String? id;
  final DateTime date;
  final String goods;
  final int amount;
  final double price_etb;

  ExpenseTrackingEntity({
    this.id,
    required this.date,
    required this.goods,
    required this.amount,
    required this.price_etb,
  });

  static ExpenseTrackingEntity fromUserInput({
    required DateTime date,
    required String goods,
    required int amount,
    required double price_etb,
  }) {
    return ExpenseTrackingEntity(
      date: date,
      goods: goods,
      amount: amount,
      price_etb: price_etb,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'goods': goods,
      'amount': amount,
      'price_etb': price_etb,
    };
  }

  factory ExpenseTrackingEntity.fromJson(Map<String, dynamic> json) {
    return ExpenseTrackingEntity(
      id: json['_id'], 
      date: DateTime.parse(json['date']),
      goods: json['goods'],
      amount: json['amount'],
      price_etb: (json['price_etb'] is int)
          ? (json['price_etb'] as int).toDouble()
          : json['price_etb'].toDouble(),
    );
  }
}

