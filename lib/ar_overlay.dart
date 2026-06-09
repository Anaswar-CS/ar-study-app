import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';

const Map<String, Map<String, dynamic>> _studyContent = {
  'topic_photosynthesis': {
    'title': '🌿 Photosynthesis',
    'image': 'assets/images/photosynthesis.png',
    'question': 'What is the equation for Photosynthesis?',
    'notes': '6CO₂ + 6H₂O + light → C₆H₁₂O₆ + 6O₂\n\n'
        '• Occurs in chloroplasts\n'
        '• Light-dependent & independent reactions\n'
        '• Produces glucose + oxygen',
  },
  'topic_mitosis': {
    'title': '🔬 Mitosis Stages',
    'image': 'assets/images/mitosis.png',
    'question': 'What are the 4 stages of Mitosis?',
    'notes': 'PMAT:\n'
        '• Prophase – chromosomes condense\n'
        '• Metaphase – line up at centre\n'
        '• Anaphase – pulled apart\n'
        '• Telophase – two new nuclei form',
  },
  'topic_newton': {
  'title': '⚡ Newton\'s Laws',
  'image': 'assets/images/newton.png',
  'question': 'What are Newton\'s 3 Laws of Motion?',
  'notes': '1️⃣  Inertia — An object stays at rest or\n'
      '     in motion unless a force acts on it\n\n'
      '2️⃣  F = ma — Force equals mass\n'
      '     multiplied by acceleration\n\n'
      '3️⃣  Action-Reaction — Every action has\n'
      '     an equal & opposite reaction',
},
};

class ArOverlay extends StatefulWidget {
  final String markerCode;
  const ArOverlay({super.key, required this.markerCode});

  @override
  State<ArOverlay> createState() => _ArOverlayState();
}

class _ArOverlayState extends State<ArOverlay>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  bool _showAnswer = false;
  bool _isSpeaking = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _tts.stop();
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showAnswer = !_showAnswer);
  }

  Future<void> _toggleSpeech(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _tts.speak(text);
      setState(() => _isSpeaking = false);
    }
  }

  void _share(Map<String, dynamic> content) {
    final text = '${content['title']}\n\n'
        'Q: ${content['question']}\n\n'
        'A: ${content['notes']}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final content = _studyContent[widget.markerCode];

    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.90),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: content != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row + action buttons
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            content['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // 🔊 TTS button
                        IconButton(
                          icon: Icon(
                            _isSpeaking ? Icons.stop_circle : Icons.volume_up,
                            color: _isSpeaking ? Colors.red : Colors.white70,
                          ),
                          onPressed: () => _toggleSpeech(
                              '${content['title']}. ${content['notes']}'),
                        ),
                        // 📤 Share button
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white70),
                          onPressed: () => _share(content),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 🃏 Flashcard flip area
                    GestureDetector(
                      onTap: _toggleFlip,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final angle = _flipAnimation.value * 3.14159;
                          final isBack = _flipAnimation.value > 0.5;
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(angle),
                            child: isBack
                                ? Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.rotationY(3.14159),
                                    child: _buildAnswer(content),
                                  )
                                : _buildQuestion(content),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Flip hint
                    Center(
                      child: Text(
                        _showAnswer
                            ? '👆 Tap to see question'
                            : '👆 Tap to reveal answer',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  '📌 Scanned: ${widget.markerCode}',
                  style: const TextStyle(color: Colors.white70),
                ),
        ),
      ),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              content['image'],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 120),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content['question'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswer(Map<String, dynamic> content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        content['notes'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }
}