class AssessmentModel {
  String id;
  String title;
  String subject;
  List<Question> questions;
  String createdBy;
  DateTime createdAt;

  AssessmentModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.questions,
    required this.createdBy,
    required this.createdAt,
  });

  factory AssessmentModel.fromMap(Map<String, dynamic> data) {
    return AssessmentModel(
      id: data['id'],
      title: data['title'],
      subject: data['subject'],
      questions: (data['questions'] as List).map((q) => Question.fromMap(q)).toList(),
      createdBy: data['createdBy'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Question {
  String question;
  List<String> options;
  int correctIndex;

  Question({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      question: data['question'],
      options: List<String>.from(data['options']),
      correctIndex: data['correctIndex'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}