class Student {
  int? id;
  String fullName;
  int price;
  DateTime startDate;
  String level;
  String? phone1;
  String? phone2;
  bool isActive;

  Student({
    this.id,
    required this.fullName,
    required this.price,
    required this.startDate,
    required this.level,
    this.phone1,
    this.phone2,
    this.isActive = true,
  });

  Student copyWith({
    int? id,
    String? fullName,
    int? price,
    DateTime? startDate,
    String? level,
    String? phone1,
    String? phone2,
    bool? isActive,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      level: level ?? this.level,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'price': price,
      'startDate': startDate.millisecondsSinceEpoch,
      'level': level,
      'phone1': phone1,
      'phone2': phone2,
      'isActive': isActive ? 1 : 0,
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
      isActive: map['isActive'] == 1 ? true : false, // [0, 1]
    );
  }
}
