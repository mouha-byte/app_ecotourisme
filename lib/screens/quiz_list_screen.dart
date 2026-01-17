import 'package:flutter/material.dart';
import 'package:ecoguide/models/quiz_model.dart';
import 'package:ecoguide/services/quiz_service.dart';
import 'package:ecoguide/utils/app_theme.dart';
import 'package:ecoguide/screens/quiz_screen.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizzes = QuizService.getMockQuizzes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz & Éducation'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuizScreen(quiz: quiz)),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      quiz.imageUrl,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.school, size: 50, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              quiz.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(quiz.difficulty).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                quiz.difficulty,
                                style: TextStyle(
                                  color: _getDifficultyColor(quiz.difficulty),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          quiz.description,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${quiz.durationMinutes} min', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(width: 16),
                            const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${quiz.questions.length} questions', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facile':
        return Colors.green;
      case 'moyen':
        return Colors.orange;
      case 'difficile':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
