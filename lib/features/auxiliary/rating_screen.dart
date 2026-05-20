import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';

/// Rating & review screen with animated stars, tag chips, confetti on submit
class RatingScreen extends StatefulWidget {
  final String bookingId;
  const RatingScreen({super.key, required this.bookingId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final List<String> _selectedTags = [];
  final _reviewController = TextEditingController();
  bool _wouldHireAgain = true;
  bool _submitted = false;
  late ConfettiController _confetti;

  static const _tags = [
    'Professional', 'On Time', 'Good Work', 'Affordable',
    'Clean & Neat', 'Friendly', 'Skilled', 'Would Recommend',
  ];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please give a star rating first'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _submitted = true);
    _confetti.play();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Stack(
        children: [
          _submitted ? _buildSuccessState(context, isDark) : _buildRatingForm(context, isDark),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 50,
              colors: const [AppTheme.primary, AppTheme.accent, AppTheme.secondary, Colors.amber, Colors.white],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingForm(BuildContext context, bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          // AppBar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppTheme.surface(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider(context))),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppTheme.textPrimary(context)),
                  ),
                ),
                const SizedBox(width: 14),
                Text('Rate Your Experience', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Worker avatar + name
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: isDark ? AppTheme.primaryDark.withOpacity(0.2) : AppTheme.primary.withOpacity(0.1),
                        child: Text('A', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 36, color: isDark ? AppTheme.primaryDark : AppTheme.primary)),
                      ),
                      const SizedBox(height: 12),
                      Text('Ali Hassan', style: Theme.of(context).textTheme.titleLarge),
                      Text('Electrician', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),

                  const SizedBox(height: 32),

                  // Star rating
                  Text('How was the service?', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 48,
                            color: i < _rating ? Colors.amber : AppTheme.divider(context),
                          ).animate(target: i < _rating ? 1 : 0)
                              .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 150.ms, curve: Curves.easeOutBack),
                        ),
                      );
                    }),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 8),
                  Text(
                    _rating == 0 ? 'Tap to rate' : _rating == 5 ? 'Excellent! 🎉' : _rating == 4 ? 'Great 👍' : _rating == 3 ? 'Good 😊' : _rating == 2 ? 'Fair 😐' : 'Poor 😞',
                    style: TextStyle(color: _rating > 0 ? Colors.amber : AppTheme.textSecondary(context), fontWeight: FontWeight.w700, fontSize: 15),
                  ).animate(delay: 300.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 28),

                  // Tag chips
                  Align(alignment: Alignment.centerLeft, child: Text('What did you like?', style: Theme.of(context).textTheme.titleSmall)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () => setState(() { if (isSelected) _selectedTags.remove(tag); else _selectedTags.add(tag); }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accent.withOpacity(0.12) : AppTheme.surface(context),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isSelected ? AppTheme.accent : AppTheme.divider(context), width: isSelected ? 1.5 : 0.5),
                          ),
                          child: Text(tag, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.accent : AppTheme.textPrimary(context))),
                        ),
                      );
                    }).toList(),
                  ).animate(delay: 350.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // Review text
                  Align(alignment: Alignment.centerLeft, child: Text('Write a review (optional)', style: Theme.of(context).textTheme.titleSmall)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: const InputDecoration(hintText: 'Share your experience...'),
                  ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  // Would hire again
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.divider(context), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Text('Would you hire again?', style: Theme.of(context).textTheme.titleSmall),
                        const Spacer(),
                        _HireToggle(value: true, selected: _wouldHireAgain, label: '👍 Yes', onTap: () => setState(() => _wouldHireAgain = true), isDark: isDark, context: context),
                        const SizedBox(width: 8),
                        _HireToggle(value: false, selected: !_wouldHireAgain, label: '👎 No', onTap: () => setState(() => _wouldHireAgain = false), isDark: isDark, context: context),
                      ],
                    ),
                  ).animate(delay: 450.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),

          // Submit button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(color: AppTheme.surface(context), border: Border(top: BorderSide(color: AppTheme.divider(context), width: 0.5))),
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, bool isDark) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24)]),
                child: const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 48)),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text('Shukria! 🎉', style: Theme.of(context).textTheme.displayMedium).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text('Aapka review submit ho gaya.\nHam aapki feedback ke liye shukarguazar hain!',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 12),
              Text('AI will remember your preferences\nfor future bookings 🤖',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.aiPurple, fontWeight: FontWeight.w600)).animate(delay: 400.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/dashboard/user'),
                child: const Text('Back to Home'),
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _HireToggle extends StatelessWidget {
  final bool value, selected, isDark;
  final String label;
  final VoidCallback onTap;
  final BuildContext context;
  const _HireToggle({required this.value, required this.selected, required this.label, required this.onTap, required this.isDark, required this.context});

  @override
  Widget build(BuildContext _) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withOpacity(0.12) : (isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.accent : Colors.transparent, width: 1.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? AppTheme.accent : AppTheme.textPrimary(context))),
      ),
    );
  }
}
