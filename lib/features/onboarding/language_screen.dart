import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Language selection screen — choose between Urdu, Roman Urdu, or English
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selected;

  static const _languages = [
    {'code': 'ur', 'label': 'اردو', 'sublabel': 'Urdu', 'flag': '🇵🇰', 'description': 'آپ کی پسندیدہ زبان'},
    {'code': 'roman', 'label': 'Roman Urdu', 'sublabel': 'Romanized Urdu', 'flag': '🇵🇰', 'description': 'Jaise aap bolte hain'},
    {'code': 'en', 'label': 'English', 'sublabel': 'English', 'flag': '🇬🇧', 'description': 'For English speakers'},
  ];

  void _selectAndContinue(String code) {
    setState(() => _selected = code);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) context.go('/role');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Header
              Text(
                'Choose Language',
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),
              Text(
                'زبان منتخب کریں',
                style: AppTheme.urduStyle(
                  fontSize: 20,
                  color: AppTheme.textSecondary(context),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 48),

              // Language options
              ...List.generate(_languages.length, (i) {
                final lang = _languages[i];
                final isSelected = _selected == lang['code'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _LanguageCard(
                    flag: lang['flag']!,
                    label: lang['label']!,
                    sublabel: lang['sublabel']!,
                    description: lang['description']!,
                    isSelected: isSelected,
                    onTap: () => _selectAndContinue(lang['code']!),
                    isDark: isDark,
                  ),
                ).animate(delay: (150 * i).ms).fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
              }),

              const Spacer(),

              // Skip
              Center(
                child: TextButton(
                  onPressed: () => context.go('/role'),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag, label, sublabel, description;
  final bool isSelected, isDark;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.label,
    required this.sublabel,
    required this.description,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(isDark ? 0.2 : 0.08)
              : AppTheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : (isDark ? AppTheme.dividerDark : const Color(0xFFEEEEEE)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag emoji in circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),

            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Check mark
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1 : 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
