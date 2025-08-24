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

// Data
class LearningData {
  static List<LearningTopic> getAllTopics() {
    return [
      getBurnTopic(),
      getWoundTopic(),
      getFractureTopic(),
    ];
  }

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
        ],
      ),
    );
  }

  static LearningTopic getWoundTopic() {
    return LearningTopic(
      id: 'wound_treatment',
      title: 'Perawatan Luka',
      description: 'Teknik dasar merawat luka ringan hingga sedang',
      icon: Icons.healing,
      gradient: [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
      materials: [
        LearningMaterial(
          id: 'wound_intro',
          title: 'Mengenal Jenis Luka',
          content: 'Luka adalah kerusakan pada jaringan tubuh yang dapat disebabkan oleh berbagai faktor. Jenis luka meliputi:\n\n• Luka sayat\n• Luka robek\n• Luka tusuk\n• Luka lecet\n• Luka memar',
          type: MaterialType.text,
        ),
        LearningMaterial(
          id: 'wound_care',
          title: 'Perawatan Luka Dasar',
          content: '1. CUCI TANGAN\n   Bersihkan tangan dengan sabun\n\n2. HENTIKAN PENDARAHAN\n   Tekan luka dengan kain bersih\n\n3. BERSIHKAN LUKA\n   Bilas dengan air bersih\n\n4. OLESKAN ANTISEPTIK\n   Gunakan betadine atau alkohol\n\n5. TUTUP LUKA\n   Pasang plester atau perban',
          type: MaterialType.steps,
        ),
      ],
      quiz: Quiz(
        id: 'wound_quiz',
        title: 'Kuis Perawatan Luka',
        questions: [
          Question(
            id: 'wq1',
            question: 'Langkah pertama dalam merawat luka adalah?',
            options: ['Cuci tangan', 'Oleskan obat', 'Tutup luka', 'Panggil dokter'],
            correctAnswer: 0,
            explanation: 'Mencuci tangan adalah langkah pertama untuk mencegah infeksi.',
          ),
        ],
      ),
    );
  }

  static LearningTopic getFractureTopic() {
    return LearningTopic(
      id: 'fracture_treatment',
      title: 'Penanganan Patah Tulang',
      description: 'Pertolongan pertama untuk cedera patah tulang',
      icon: Icons.accessible_forward,
      gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
      materials: [
        LearningMaterial(
          id: 'fracture_intro',
          title: 'Mengenali Patah Tulang',
          content: 'Patah tulang adalah terputusnya kontinuitas tulang. Tanda-tanda:\n\n• Nyeri hebat\n• Bengkak\n• Deformitas\n• Ketidakmampuan bergerak\n• Bunyi patah saat cedera',
          type: MaterialType.text,
        ),
        LearningMaterial(
          id: 'fracture_aid',
          title: 'Pertolongan Pertama',
          content: '1. JANGAN GERAKKAN KORBAN\n   Stabilkan posisi\n\n2. IMMOBILISASI\n   Pasang bidai pada area patah\n\n3. KOMPRES ES\n   Kurangi bengkak dan nyeri\n\n4. ELEVASI\n   Angkat bagian yang cedera\n\n5. RUJUK KE RS\n   Segera bawa ke rumah sakit',
          type: MaterialType.steps,
        ),
      ],
      quiz: Quiz(
        id: 'fracture_quiz',
        title: 'Kuis Patah Tulang',
        questions: [
          Question(
            id: 'fq1',
            question: 'Hal pertama yang dilakukan pada korban patah tulang?',
            options: ['Pindahkan korban', 'Stabilkan posisi', 'Beri obat', 'Urut area patah'],
            correctAnswer: 1,
            explanation: 'Stabilkan posisi korban untuk mencegah cedera lebih lanjut.',
          ),
        ],
      ),
    );
  }
}

// Theme Colors
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

// Main Topic Selection Screen
class LearningHomeScreen extends StatefulWidget {
  const LearningHomeScreen({Key? key}) : super(key: key);

  @override
  State<LearningHomeScreen> createState() => _LearningHomeScreenState();
}

class _LearningHomeScreenState extends State<LearningHomeScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topics = LearningData.getAllTopics();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Pembelajaran P3K',
          style: TextStyle(
            color: AppTheme.whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Topik Pembelajaran',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pelajari teknik pertolongan pertama yang tepat',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                ...topics.asMap().entries.map((entry) {
                  final index = entry.key;
                  final topic = entry.value;
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200 + (index * 100)),
                    curve: Curves.easeInOut,
                    child: _buildTopicCard(topic, index),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(LearningTopic topic, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.largeRadius,
        elevation: 0,
        child: InkWell(
          borderRadius: AppTheme.largeRadius,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MaterialDetailScreen(topic: topic),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    )),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: AppTheme.largeRadius,
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: topic.gradient),
                    borderRadius: AppTheme.mediumRadius,
                  ),
                  child: Icon(
                    topic.icon,
                    size: 32,
                    color: AppTheme.whiteColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${topic.materials.length} Materi',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.quiz,
                            size: 16,
                            color: AppTheme.warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${topic.quiz.questions.length} Kuis',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textTertiaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Material Detail Screen
class MaterialDetailScreen extends StatefulWidget {
  final LearningTopic topic;

  const MaterialDetailScreen({Key? key, required this.topic}) : super(key: key);

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> 
    with TickerProviderStateMixin {
  int currentMaterialIndex = 0;
  late AnimationController _contentAnimationController;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_contentAnimationController);
    
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOut,
    ));

    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _animateContentChange() {
    _contentAnimationController.reset();
    _contentAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final material = widget.topic.materials[currentMaterialIndex];
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          widget.topic.title,
          style: const TextStyle(color: AppTheme.whiteColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: _buildMaterialCard(material),
                ),
              ),
            ),
          ),
          _buildNavigationSection(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (currentMaterialIndex + 1) / widget.topic.materials.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Materi ${currentMaterialIndex + 1} dari ${widget.topic.materials.length}',
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
            blurRadius: 8,
            offset: const Offset(0, 2),
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
          _buildMaterialContent(material),
        ],
      ),
    );
  }

  Widget _buildMaterialContent(LearningMaterial material) {
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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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

  Widget _buildNavigationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          if (currentMaterialIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    currentMaterialIndex--;
                  });
                  _animateContentChange();
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
                if (currentMaterialIndex < widget.topic.materials.length - 1) {
                  setState(() {
                    currentMaterialIndex++;
                  });
                  _animateContentChange();
                } else {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          QuizScreen(
                        quiz: widget.topic.quiz,
                        onComplete: (result) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  QuizResultScreen(
                                result: result,
                                topic: widget.topic,
                              ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
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
                currentMaterialIndex < widget.topic.materials.length - 1 
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
      ),
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

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = [];
  bool isAnswered = false;
  bool showExplanation = false;
  late AnimationController _questionAnimationController;
  late Animation<double> _questionFadeAnimation;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(widget.quiz.questions.length, null);
    
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _questionFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_questionAnimationController);

    _questionAnimationController.forward();
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    super.dispose();
  }

  void _animateQuestionChange() {
    _questionAnimationController.reset();
    _questionAnimationController.forward();
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
            child: FadeTransition(
              opacity: _questionFadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildQuestionCard(question),
                    const SizedBox(height: 20),
                    _buildAnswerOptions(question),
                    if (showExplanation) 
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildExplanation(question),
                      ),
                  ],
                ),
              ),
            ),
          ),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildQuizProgress() {
    final progress = (currentQuestionIndex + 1) / widget.quiz.questions.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
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
            blurRadius: 8,
            offset: const Offset(0, 2),
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
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
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

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                        option,
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
      }).toList(),
    );
  }

  Widget _buildExplanation(Question question) {
    return Container(
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
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
      _animateQuestionChange();
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

    widget.onComplete(result);
  }
}

// Quiz Result Screen
class QuizResultScreen extends StatefulWidget {
  final QuizResult result;
  final LearningTopic topic;

  const QuizResultScreen({
    Key? key,
    required this.result,
    required this.topic,
  }) : super(key: key);

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExcellent = widget.result.percentage >= 80;
    final isGood = widget.result.percentage >= 60;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Hasil Kuis',
          style: TextStyle(color: AppTheme.whiteColor),
        ),
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SingleChildScrollView(
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
                        'Skor: ${widget.result.score}/100',
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
                          _buildStatItem('Benar', '${widget.result.correctAnswers}', AppTheme.successColor),
                          _buildStatItem('Salah', '${widget.result.totalQuestions - widget.result.correctAnswers}', AppTheme.errorColor),
                          _buildStatItem('Persentase', '${widget.result.percentage.round()}%', AppTheme.primaryColor),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const LearningHomeScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(-1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.mediumRadius,
                          ),
                        ),
                        child: const Text(
                          'Kembali ke Beranda',
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  MaterialDetailScreen(topic: widget.topic),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.mediumRadius,
                          ),
                        ),
                        child: const Text(
                          'Ulangi Materi',
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