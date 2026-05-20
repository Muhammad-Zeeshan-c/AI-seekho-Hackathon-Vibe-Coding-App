import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_ai_sekho_project/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/language_notifier.dart';

/// Language selection screen — choose between Urdu or English
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  // Pre-select English
  String _selectedCode = 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set default without saving to prefs yet
      ref.read(languageNotifierProvider.notifier).state = const Locale('en');
    });
  }

  void _selectLanguage(String code) {
    setState(() => _selectedCode = code);
    ref.read(languageNotifierProvider.notifier).state = Locale(code);
  }

  void _continue() async {
    await ref.read(languageNotifierProvider.notifier).setLanguage(_selectedCode);
    if (mounted) context.go('/role');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // If l10n is null (building before delegates load), return empty
    if (l10n == null) return const Scaffold();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Header (Localized)
              Text(
                l10n.chooseLanguage,
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 48),

              // English Option
              _LanguageCard(
                flag: '🇬🇧',
                label: 'English',
                description: 'For English speakers',
                isSelected: _selectedCode == 'en',
                isDark: isDark,
                onTap: () => _selectLanguage('en'),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: 16),

              // Urdu Option
              _LanguageCard(
                flag: '🇵🇰',
                label: 'اردو',
                description: 'اپنی پسندیدہ زبان منتخب کریں',
                isSelected: _selectedCode == 'ur',
                isDark: isDark,
                onTap: () => _selectLanguage('ur'),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

              const Spacer(),

              // Continue Button
              ElevatedButton(
                onPressed: _continue,
                child: Text(l10n.continueButton),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag, label, description;
  final bool isSelected, isDark;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.label,
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
            // Flag emoji
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
                    style: TextStyle(
                      fontFamily: label == 'اردو' ? 'JameelNooriNastaleeq' : 'PlusJakartaSans',
                      fontSize: label == 'اردو' ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primary : AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: label == 'اردو' ? 'NotoNastaliqUrdu' : 'Inter',
                      fontSize: label == 'اردو' ? 14 : 12,
                      color: AppTheme.textSecondary(context),
                    ),
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
