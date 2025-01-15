class UserModel {
  String? createdAt;
  String? name;
  String? username;
  String? password;
  String? balance;
  String? id;

  UserModel(
      {this.createdAt,
        this.name,
        this.username,
        this.password,
        this.balance,
        this.id});

  UserModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    name = json['name'];
    username = json['username'];
    password = json['password'];
    balance = json['balance'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['name'] = this.name;
    data['username'] = this.username;
    data['password'] = this.password;
    data['balance'] = this.balance;
    data['id'] = this.id;
    return data;
  }
}
