class Lesson {
  int? id;
  int studentId;
  DateTime dateTime;
  double duration; // 1 или 2 часа
  double amount; // сумма на момент урока (фиксированная)
  bool isCompleted;
  String? comment;

  Lesson({
    this.id,
    required this.studentId,
    required this.dateTime,
    required this.duration,
    required this.amount,
    this.isCompleted = false,
    this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'duration': duration,
      'amount': amount,
      'isCompleted': isCompleted ? 1 : 0,
      'comment': comment,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      studentId: map['studentId'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      duration: (map['duration'] as num).toDouble(),
      amount: (map['amount'] as num).toDouble(),
      isCompleted: (map['isCompleted'] as int?) == 1,
      comment: map['comment'],
    );
  }
}
