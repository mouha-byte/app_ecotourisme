import 'package:flutter/material.dart';
import 'package:ecoguide/models/quiz_model.dart';
import 'package:ecoguide/utils/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedOptionIndex;

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
            const SizedBox(height: 24),
            
            // Question Counter
            Text(
              'Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Question Text
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Options
            ...List.generate(question.options.length, (index) {
              return _buildOptionCard(index, question);
            }),
            
            const Spacer(),
            
            // Bottom Button (Next or Finish)
            if (_isAnswered)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _currentQuestionIndex < widget.quiz.questions.length - 1
                      ? 'Question Suivante'
                      : 'Voir les résultats',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index, Question question) {
    final isSelected = _selectedOptionIndex == index;
    final isCorrect = index == question.correctOptionIndex;
    
    Color borderColor = Colors.grey.shade300;
    Color backgroundColor = Colors.white;
    IconData? icon;
    Color iconColor = Colors.transparent;

    if (_isAnswered) {
      if (isCorrect) {
        borderColor = Colors.green;
        backgroundColor = Colors.green.shade50;
        icon = Icons.check_circle;
        iconColor = Colors.green;
      } else if (isSelected) {
        borderColor = Colors.red;
        backgroundColor = Colors.red.shade50;
        icon = Icons.cancel;
        iconColor = Colors.red;
      }
    } else if (isSelected) {
      borderColor = AppTheme.primaryGreen;
      backgroundColor = AppTheme.primaryGreen.withOpacity(0.05);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _isAnswered ? null : () => _handleAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  question.options[index],
                  style: TextStyle(
                    fontSize: 16,
                    color: _isAnswered && !isCorrect && !isSelected 
                        ? Colors.grey 
                        : Colors.black87,
                    fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAnswer(int selectedIndex) {
    setState(() {
      _selectedOptionIndex = selectedIndex;
      _isAnswered = true;
      if (selectedIndex == widget.quiz.questions[_currentQuestionIndex].correctOptionIndex) {
        _score++;
      }
    });
    
    // Show explanation if needed (optional toast or modal)
    if (widget.quiz.questions[_currentQuestionIndex].explanation.isNotEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(widget.quiz.questions[_currentQuestionIndex].explanation),
           duration: const Duration(seconds: 4),
           behavior: SnackBarBehavior.floating,
         ),
       );
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedOptionIndex = null;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultScreen(
          score: _score,
          totalQuestions: widget.quiz.questions.length,
          onRestart: () {
            Navigator.pop(context); // Remove result screen
            Navigator.pushReplacement( // Re-push quiz screen
              context,
              MaterialPageRoute(builder: (_) => QuizScreen(quiz: widget.quiz)),
            );
          },
        ),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRestart;

  const _ResultScreen({
    required this.score,
    required this.totalQuestions,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                percentage >= 70 ? Icons.emoji_events : Icons.sentiment_satisfied,
                size: 80,
                color: percentage >= 70 ? Colors.amber : Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                percentage >= 70 ? 'Félicitations !' : 'Bien joué !',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Vous avez obtenu $score sur $totalQuestions',
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context), // Go back to list
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retour à la liste'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRestart,
                child: const Text('Recommencer le quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
