import 'package:flutter/material.dart';

// Models
class LearningTopic {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final List<LearningMaterial> materials;
  final Quiz quiz;

  LearningTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.materials,
    required this.quiz,
  });
}

class LearningMaterial {
  final String id;
  final String title;
  final String content;
  final String? imageAsset;
  final MaterialType type;

  LearningMaterial({
    required this.id,
    required this.title,
    required this.content,
    this.imageAsset,
    this.type = MaterialType.text,
  });
}

enum MaterialType { text, image, video, steps }

class Quiz {
  final String id;
  final String title;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
  });
}

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final List<bool> answers;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.answers,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;
}

// Dummy Data
class LearningData {
  static LearningTopic getBurnTopic() {
    return LearningTopic(
      id: 'burn_treatment',
      title: 'Penanganan Luka Bakar',
      description: 'Pelajari cara menangani luka bakar dengan tepat dan aman',
      icon: Icons.local_fire_department,
      gradient: [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
      materials: [
        LearningMaterial(
          id: 'burn_intro',
          title: 'Apa itu Luka Bakar?',
          content: 'Luka bakar adalah kerusakan jaringan yang disebabkan oleh panas, bahan kimia, listrik, atau radiasi. Luka bakar dapat terjadi pada kulit dan jaringan di bawahnya.\n\nTingkat keparahan luka bakar dibagi menjadi tiga derajat:\n\n• Derajat 1: Hanya mengenai lapisan terluar kulit\n• Derajat 2: Mengenai lapisan kulit yang lebih dalam\n• Derajat 3: Mengenai seluruh ketebalan kulit',
          type: MaterialType.text,
        ),
        LearningMaterial(
          id: 'burn_types',
          title: 'Jenis-jenis Luka Bakar',
          content: '1. LUKA BAKAR PANAS\n   Disebabkan oleh api, air panas, uap, atau benda panas\n\n2. LUKA BAKAR KIMIA\n   Disebabkan oleh asam, basa, atau bahan kimia lainnya\n\n3. LUKA BAKAR LISTRIK\n   Disebabkan oleh arus listrik\n\n4. LUKA BAKAR RADIASI\n   Disebabkan oleh sinar matahari atau radiasi medis',
          type: MaterialType.text,
        ),
        LearningMaterial(
          id: 'first_aid_steps',
          title: 'Langkah Pertolongan Pertama',
          content: '1. HENTIKAN PROSES TERBAKAR\n   Jauhkan dari sumber panas\n\n2. DINGINKAN LUKA\n   Siram dengan air mengalir 10-20 menit\n\n3. LEPAS AKSESORIS\n   Lepas perhiasan sebelum bengkak\n\n4. TUTUP LUKA\n   Gunakan kain bersih dan lembab\n\n5. CARI BANTUAN MEDIS\n   Segera ke rumah sakit untuk luka berat',
          type: MaterialType.steps,
        ),
        LearningMaterial(
          id: 'what_not_to_do',
          title: 'Yang TIDAK Boleh Dilakukan',
          content: '❌ JANGAN gunakan es batu\n❌ JANGAN pecah gelembung\n❌ JANGAN oleskan mentega atau minyak\n❌ JANGAN gunakan pasta gigi\n❌ JANGAN lepas pakaian yang menempel\n❌ JANGAN sentuh luka dengan tangan kotor',
          type: MaterialType.text,
        ),
      ],
      quiz: Quiz(
        id: 'burn_quiz',
        title: 'Kuis Penanganan Luka Bakar',
        questions: [
          Question(
            id: 'q1',
            question: 'Langkah pertama dalam menangani luka bakar adalah?',
            options: [
              'Oleskan mentega pada luka',
              'Hentikan proses terbakar',
              'Pecahkan gelembung yang terbentuk',
              'Berikan obat pereda nyeri'
            ],
            correctAnswer: 1,
            explanation: 'Langkah pertama adalah menghentikan proses terbakar dengan menjauhkan korban dari sumber panas.',
          ),
          Question(
            id: 'q2',
            question: 'Berapa lama kita harus menyiram luka bakar dengan air mengalir?',
            options: ['5 menit', '10-20 menit', '30 menit', '1 jam'],
            correctAnswer: 1,
            explanation: 'Luka bakar harus disiram dengan air mengalir selama 10-20 menit untuk mendinginkan jaringan.',
          ),
          Question(
            id: 'q3',
            question: 'Apa yang TIDAK boleh dilakukan pada luka bakar?',
            options: [
              'Siram dengan air bersih',
              'Tutup dengan kain bersih',
              'Oleskan pasta gigi',
              'Cari bantuan medis'
            ],
            correctAnswer: 2,
            explanation: 'Pasta gigi tidak boleh dioleskan pada luka bakar karena dapat menyebabkan infeksi dan memperburuk luka.',
          ),
          Question(
            id: 'q4',
            question: 'Luka bakar derajat 3 mengenai:',
            options: [
              'Hanya lapisan terluar kulit',
              'Lapisan kulit yang lebih dalam',
              'Seluruh ketebalan kulit',
              'Hanya rambut'
            ],
            correctAnswer: 2,
            explanation: 'Luka bakar derajat 3 mengenai seluruh ketebalan kulit dan merupakan yang paling parah.',
          ),
          Question(
            id: 'q5',
            question: 'Mengapa perhiasan harus dilepas pada korban luka bakar?',
            options: [
              'Agar tidak hilang',
              'Mencegah pembengkakan yang terjepit',
              'Perhiasan bisa mencair',
              'Mengurangi rasa sakit'
            ],
            correctAnswer: 1,
            explanation: 'Perhiasan harus dilepas sebelum terjadi pembengkakan yang dapat menyebabkan terjepit dan memperburuk cedera.',
          ),
        ],
      ),
    );
  }
}

// Theme Colors (menggunakan tema dari file Anda)
class AppTheme {
  static const Color primaryColor = Color(0xFF00796B);
  static const Color accentColor = Color(0xFF81C784);
  static const Color secondaryColor = Color(0xFFB3E5FC);
  static const Color surfaceColor = Color(0xFFFAFBFC);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color textPrimaryColor = Color(0xFF1A202C);
  static const Color textSecondaryColor = Color(0xFF4A5568);
  static const Color textTertiaryColor = Color(0xFF718096);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color errorColor = Color(0xFFE57373);
  
  static BorderRadius smallRadius = BorderRadius.circular(8);
  static BorderRadius mediumRadius = BorderRadius.circular(12);
  static BorderRadius largeRadius = BorderRadius.circular(16);
  static BorderRadius xLargeRadius = BorderRadius.circular(20);
}

// Main Learning Screen
class InteractiveLearningScreen extends StatefulWidget {
  const InteractiveLearningScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveLearningScreen> createState() => _InteractiveLearningScreenState();
}

class _InteractiveLearningScreenState extends State<InteractiveLearningScreen> {
  late LearningTopic topic;
  int currentMaterialIndex = 0;
  bool hasStartedLearning = false;
  bool hasCompletedMaterials = false;
  QuizResult? quizResult;

  @override
  void initState() {
    super.initState();
    topic = LearningData.getBurnTopic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (!hasStartedLearning) _buildTopicOverview(),
          if (hasStartedLearning && !hasCompletedMaterials) _buildMaterialContent(),
          if (hasCompletedMaterials && quizResult == null) _buildQuizSection(),
          if (quizResult != null) _buildQuizResult(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          topic.title,
          style: const TextStyle(
            color: AppTheme.whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicOverview() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            _buildTopicCard(),
            const SizedBox(height: 24),
            _buildProgressSection(),
            const SizedBox(height: 24),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.largeRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: topic.gradient),
              borderRadius: AppTheme.mediumRadius,
            ),
            child: Icon(
              topic.icon,
              size: 48,
              color: AppTheme.whiteColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            topic.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            topic.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.mediumRadius,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yang akan Anda pelajari:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ...topic.materials.map((material) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    material.title,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.quiz,
                size: 20,
                color: AppTheme.warningColor,
              ),
              const SizedBox(width: 8),
              Text(
                '${topic.quiz.questions.length} Pertanyaan Kuis',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            hasStartedLearning = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.mediumRadius,
          ),
        ),
        child: const Text(
          'Mulai Belajar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.whiteColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialContent() {
    final material = topic.materials[currentMaterialIndex];
    
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            _buildProgressBar(),
            const SizedBox(height: 20),
            _buildMaterialCard(material),
            const SizedBox(height: 20),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (currentMaterialIndex + 1) / topic.materials.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.mediumRadius,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Materi ${currentMaterialIndex + 1} dari ${topic.materials.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.borderColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(LearningMaterial material) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.largeRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            material.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildPelajaranContent(material),
        ],
      ),
    );
  }

  Widget _buildPelajaranContent(LearningMaterial material) {
    if (material.type == MaterialType.steps) {
      return _buildStepsContent(material.content);
    }
    return Text(
      material.content,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: AppTheme.textSecondaryColor,
      ),
    );
  }

  Widget _buildStepsContent(String content) {
    final steps = content.split('\n\n');
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppTheme.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (currentMaterialIndex > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  currentMaterialIndex--;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.mediumRadius,
                ),
              ),
              child: const Text(
                'Sebelumnya',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ),
        if (currentMaterialIndex > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (currentMaterialIndex < topic.materials.length - 1) {
                setState(() {
                  currentMaterialIndex++;
                });
              } else {
                setState(() {
                  hasCompletedMaterials = true;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.mediumRadius,
              ),
            ),
            child: Text(
              currentMaterialIndex < topic.materials.length - 1 
                  ? 'Selanjutnya' 
                  : 'Mulai Kuis',
              style: const TextStyle(
                color: AppTheme.whiteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: topic.gradient),
            borderRadius: AppTheme.largeRadius,
          ),
          child: Column(
            children: [
              const Icon(
                Icons.quiz,
                size: 64,
                color: AppTheme.whiteColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Saatnya Kuis!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.whiteColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Uji pemahaman Anda dengan ${topic.quiz.questions.length} pertanyaan',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.whiteColor.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          quiz: topic.quiz,
                          onComplete: (result) {
                            setState(() {
                              quizResult = result;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.mediumRadius,
                    ),
                  ),
                  child: Text(
                    'Mulai Kuis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: topic.gradient.first,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizResult() {
    final result = quizResult!;
    final isExcellent = result.percentage >= 80;
    final isGood = result.percentage >= 60;
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: AppTheme.largeRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isExcellent ? Icons.emoji_events : isGood ? Icons.thumb_up : Icons.refresh,
                    size: 64,
                    color: isExcellent ? AppTheme.warningColor : isGood ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isExcellent ? 'Luar Biasa!' : isGood ? 'Bagus!' : 'Perlu Latihan Lagi',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Skor: ${result.score}/100',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Benar', '${result.correctAnswers}', AppTheme.successColor),
                      _buildStatItem('Salah', '${result.totalQuestions - result.correctAnswers}', AppTheme.errorColor),
                      _buildStatItem('Persentase', '${result.percentage.round()}%', AppTheme.primaryColor),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        hasStartedLearning = false;
                        hasCompletedMaterials = false;
                        currentMaterialIndex = 0;
                        quizResult = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.mediumRadius,
                      ),
                    ),
                    child: const Text(
                      'Ulangi Materi',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        quizResult = null;
                        hasCompletedMaterials = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.mediumRadius,
                      ),
                    ),
                    child: const Text(
                      'Ulangi Kuis',
                      style: TextStyle(
                        color: AppTheme.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

// Quiz Screen
class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  final Function(QuizResult) onComplete;

  const QuizScreen({
    Key? key,
    required this.quiz,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = [];
  bool isAnswered = false;
  bool showExplanation = false;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(widget.quiz.questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Kuis ${currentQuestionIndex + 1}/${widget.quiz.questions.length}',
          style: const TextStyle(color: AppTheme.whiteColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildQuizProgress(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionCard(question),
                  const SizedBox(height: 20),
                  Expanded(child: _buildAnswerOptions(question)),
                  if (showExplanation) _buildExplanation(question),
                  _buildActionButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizProgress() {
    final progress = (currentQuestionIndex + 1) / widget.quiz.questions.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pertanyaan ${currentQuestionIndex + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.borderColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.largeRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        question.question,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimaryColor,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(Question question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final isSelected = selectedAnswers[currentQuestionIndex] == index;
        final isCorrect = index == question.correctAnswer;
        final isWrong = isAnswered && isSelected && !isCorrect;
        final shouldHighlightCorrect = isAnswered && isCorrect;

        Color backgroundColor = AppTheme.cardColor;
        Color borderColor = AppTheme.borderColor;
        Color textColor = AppTheme.textPrimaryColor;

        if (shouldHighlightCorrect) {
          backgroundColor = AppTheme.successColor.withOpacity(0.1);
          borderColor = AppTheme.successColor;
          textColor = AppTheme.successColor;
        } else if (isWrong) {
          backgroundColor = AppTheme.errorColor.withOpacity(0.1);
          borderColor = AppTheme.errorColor;
          textColor = AppTheme.errorColor;
        } else if (isSelected && !isAnswered) {
          backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
          borderColor = AppTheme.primaryColor;
          textColor = AppTheme.primaryColor;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: backgroundColor,
            borderRadius: AppTheme.mediumRadius,
            child: InkWell(
              borderRadius: AppTheme.mediumRadius,
              onTap: isAnswered ? null : () {
                setState(() {
                  selectedAnswers[currentQuestionIndex] = index;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: AppTheme.mediumRadius,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: textColor, width: 2),
                        color: isSelected ? textColor : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppTheme.whiteColor,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (shouldHighlightCorrect)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 24,
                      ),
                    if (isWrong)
                      const Icon(
                        Icons.cancel,
                        color: AppTheme.errorColor,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExplanation(Question question) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.2),
        borderRadius: AppTheme.mediumRadius,
        border: Border.all(color: AppTheme.secondaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Penjelasan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final hasAnswer = selectedAnswers[currentQuestionIndex] != null;
    final isLastQuestion = currentQuestionIndex == widget.quiz.questions.length - 1;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: hasAnswer ? _handleButtonPress : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            disabledBackgroundColor: AppTheme.borderColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.mediumRadius,
            ),
          ),
          child: Text(
            _getButtonText(isLastQuestion),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: hasAnswer ? AppTheme.whiteColor : AppTheme.textTertiaryColor,
            ),
          ),
        ),
      ),
    );
  }

  String _getButtonText(bool isLastQuestion) {
    if (!isAnswered) return 'Jawab';
    if (showExplanation) {
      return isLastQuestion ? 'Selesai' : 'Lanjut';
    }
    return 'Lihat Penjelasan';
  }

  void _handleButtonPress() {
    if (!isAnswered) {
      setState(() {
        isAnswered = true;
      });
    } else if (!showExplanation) {
      setState(() {
        showExplanation = true;
      });
    } else {
      _nextQuestion();
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        showExplanation = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    int correctAnswers = 0;
    List<bool> answers = [];

    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final isCorrect = selectedAnswers[i] == widget.quiz.questions[i].correctAnswer;
      answers.add(isCorrect);
      if (isCorrect) correctAnswers++;
    }

    final result = QuizResult(
      totalQuestions: widget.quiz.questions.length,
      correctAnswers: correctAnswers,
      score: ((correctAnswers / widget.quiz.questions.length) * 100).round(),
      answers: answers,
    );

    Navigator.pop(context);
    widget.onComplete(result);
  }
}