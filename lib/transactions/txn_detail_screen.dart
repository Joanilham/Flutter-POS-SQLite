class Txn {
  final int? id;
  final double total;
  final String datetime;
  final int? userId;

  const Txn({
    this.id,
    required this.total,
    required this.datetime,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'datetime': datetime,
      'user_id': userId,
    };
  }

  factory Txn.fromMap(Map<String, dynamic> map) {
    return Txn(
      id: map['id']?.toInt(),
      total: map['total']?.toDouble() ?? 0.0,
      datetime: map['datetime'] ?? '',
      userId: map['user_id']?.toInt(),
    );
  }
}