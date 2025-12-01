class Lesson {
  int? id;
  int studentId;
  DateTime dateTime;
  double duration; // 1 или 2 часа
  double amount; // сумма на момент урока (фиксированная)

  Lesson({
    this.id,
    required this.studentId,
    required this.dateTime,
    required this.duration,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'duration': duration,
      'amount': amount,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      studentId: map['studentId'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      duration: (map['duration'] as num).toDouble(),
      amount: (map['amount'] as num).toDouble(),
    );
  }
}
