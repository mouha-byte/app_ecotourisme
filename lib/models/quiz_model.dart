class Quiz {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String difficulty; // 'easy', 'medium', 'hard'
  final int durationMinutes;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.difficulty,
    required this.durationMinutes,
    required this.questions,
  });
}

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}
