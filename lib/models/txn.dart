class Txn {
  int? id;
  double total;
  String datetime;
  int userId;
  List<TxnDetail> details;

  Txn({
    this.id,
    required this.total,
    required this.datetime,
    required this.userId,
    this.details = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'datetime': datetime,
      'user_id': userId,
    };
  }
}

class TxnDetail {
  int? id;
  int? txnId;
  int itemId;
  int quantity;

  TxnDetail({
    this.id,
    this.txnId,
    required this.itemId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'txn_id': txnId,
      'item_id': itemId,
      'quantity': quantity,
    };
  }
}