class Student {
  int? id;
  String fullName;
  int price;

  Student({this.id, required this.fullName, required this.price});

  Map<String, dynamic> toMap() {
    return {'id': id, 'fullName': fullName, 'price': price};
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      fullName: map['fullName'],
      price: map['price'],
    );
  }
}
