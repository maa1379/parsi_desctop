class WalletModel {
  String id;
  String balance;
  String user;
  List<TransactionModel> transactions;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  WalletModel({
    required this.id,
    required this.balance,
    required this.user,
    required this.transactions,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        id: json["_id"],
        balance: json["balance"],
        user: json["user"],
        transactions: List<TransactionModel>.from(json["transactions"].map((x) => TransactionModel.fromJson(x))),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "balance": balance,
        "user": user,
        "transactions": List<dynamic>.from(transactions.map((x) => x)),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

class TransactionModel {
  String id;
  String amount;
  String payId;
  bool isPaid;
  bool statusTransaction;
  String wallet;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.payId,
    required this.isPaid,
    required this.statusTransaction,
    required this.wallet,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json["_id"],
        amount: json["amount"],
        payId: json["pay_id"] ?? "",
        isPaid: json["is_paid"],
        statusTransaction: json["status_transaction"],
        wallet: json["wallet"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "amount": amount,
        "pay_id": payId,
        "is_paid": isPaid,
        "status_transaction": statusTransaction,
        "wallet": wallet,
      };
}
