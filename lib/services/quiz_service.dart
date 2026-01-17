import 'package:ecoguide/models/quiz_model.dart';

class QuizService {
  static List<Quiz> getMockQuizzes() {
    return [
      Quiz(
        id: '1',
        title: 'Faune & Flore de Mogods',
        description: 'Testez vos connaissances sur les espèces endémiques de la région de Cap Negro et Djebel Chitana.',
        imageUrl: 'assets/images/quiz_cover.png',
        difficulty: 'Facile',
        durationMinutes: 5,
        questions: [
          Question(
            id: 'q1',
            text: 'Quel est l\'arbre emblématique de la forêt de Djebel Chitana ?',
            options: ['Le Pin d\'Alep', 'Le Chêne-liège', 'L\'Olivier sauvage', 'Le Palmier'],
            correctOptionIndex: 1,
            explanation: 'Le Chêne-liège (Quercus suber) est l\'espèce dominante de la forêt, exploitée durablement pour son écorce.',
          ),
          Question(
            id: 'q2',
            text: 'Quel grand mammifère peut-on croiser discrètement dans la région ?',
            options: ['L\'Ours brun', 'Le Cerf de Barbarie', 'Le Loup gris', 'Le Lion'],
            correctOptionIndex: 1,
            explanation: 'Le Cerf de Barbarie (Cervus elaphus barbarus) est le seul cerf d\'Afrique, réintroduit dans certaines zones de Mogods.',
          ),
        ],
      ),
      Quiz(
        id: '2',
        title: 'Les Bons Gestes ',
        description: 'Savez-vous comment minimiser votre impact lors d\'une randonnée ?',
        imageUrl: 'assets/images/quiz_cover.png',
        difficulty: 'Moyen',
        durationMinutes: 3,
        questions: [
          Question(
            id: 'q1',
            text: 'Que faire de ses déchets organiques (peau de banane, trognon de pomme) ?',
            options: ['Les jeter dans un buisson', 'Les enterrer', 'Les remporter avec soi', 'Les donner aux animaux'],
            correctOptionIndex: 2,
            explanation: 'Même biodégradables, ils peuvent perturber l\'écosystème local ou le régime alimentaire des animaux sauvages. Emportez tout !',
          ),
          Question(
            id: 'q2',
            text: 'En randonnée, quelle est la règle pour l\'observation des animaux ?',
            options: ['S\'approcher pour une photo', 'Leur donner à manger', 'Rester à distance et silencieux', 'Faire du bruit pour les prévenir'],
            correctOptionIndex: 2,
            explanation: 'Il faut éviter de les stresser. Utilisez des jumelles et restez sur les sentiers.',
          ),
        ],
      ),
    ];
  }
}
