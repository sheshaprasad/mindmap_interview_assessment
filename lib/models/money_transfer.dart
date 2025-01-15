class Transaction {
  String? createdAt;
  String? amount;
  String? id;
  String? userId;

  Transaction({this.createdAt, this.amount, this.id, this.userId});

  Transaction.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    amount = json['amount'];
    id = json['id'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['amount'] = this.amount;
    data['id'] = this.id;
    data['userId'] = this.userId;
    return data;
  }
}


class Payee{
  String name;

  Payee(this.name);

}