import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';

/// Screen allowing client feedback submissions after a service is marked completed
class RatingScreen extends StatefulWidget {
  final String bookingId;
  const RatingScreen({super.key, required this.bookingId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  late ConfettiController _confettiController;
  int _rating = 5;
  final _commentController = TextEditingController();
  final List<String> _feedbackTags = ['Punctual', 'Fair Price', 'Polite', 'Expert work', 'Clean up done'];
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play(); // Play congratulations celebration
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted! Thank you / شکریہ')),
    );
    context.go('/dashboard/user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Review & Rating'),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Confetti overlay
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    '🎉 Job Completed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accent),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Aap ka kaam kamyabi se mukammal ho gaya hai.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Star ratings row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIdx = index + 1;
                    final isSelected = starIdx <= _rating;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = starIdx),
                      child: Icon(
                        Icons.star_rounded,
                        color: isSelected ? Colors.amber : Colors.black12,
                        size: 48,
                      ).animate(target: isSelected ? 1.0 : 0.0).scale(begin: const Offset(1.0, 1.0), end: const Offset(1.2, 1.2)),
                    );
                  }),
                ),
                
                const SizedBox(height: 32),
                
                // Feedback tag selection
                const Text('What went well?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _feedbackTags.map<Widget>((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return ChoiceChip(
                      label: Text(tag),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimary),
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                // Written review field
                const Text('Write a Comment / تبصرہ لکھیں', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with this worker...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: _submitReview,
                  child: const Text('Submit Review / جمع کرائیں'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
