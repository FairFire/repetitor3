class Student {
  int? id;
  String fullName;
  int price;
  DateTime startDate;
  String level;
  String? phone1;
  String? phone2;

  Student({
    this.id,
    required this.fullName,
    required this.price,
    required this.startDate,
    required this.level,
    this.phone1,
    this.phone2,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'price': price,
      'startDate': startDate.millisecondsSinceEpoch,
      'level': level,
      'phone1': phone1,
      'phone2': phone2,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      fullName: map['fullName'],
      price: map['price'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      level: map['level'],
      phone1: map['phone1'],
      phone2: map['phone2'],
    );
  }
}
