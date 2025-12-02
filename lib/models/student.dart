class Student {
  int? id;
  String fullName;
  int price;
  DateTime startDate;
  String level;

  Student({
    this.id,
    required this.fullName,
    required this.price,
    required this.startDate,
    required this.level,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'price': price,
      'startDate': startDate.millisecondsSinceEpoch,
      'level': level,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      fullName: map['fullName'],
      price: map['price'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      level: map['level'],
    );
  }
}
