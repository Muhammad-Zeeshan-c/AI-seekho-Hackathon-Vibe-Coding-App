import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

/// Role selection — bold split layout: Client vs Service Worker
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Header
              Text(
                l10n.areYouClientOrWorker,
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 36),

              // Client card
              _RoleCard(
                emoji: '🏠',
                title: l10n.client,
                description: l10n.clientDesc,
                accentColor: AppTheme.primary,
                gradientColors: isDark
                    ? [const Color(0xFF0D1F3C), const Color(0xFF0A1628)]
                    : [const Color(0xFFE8F1FF), const Color(0xFFF0F6FF)],
                badgeLabel: 'CLIENT',
                onTap: () => context.push('/login/user'),
                isDark: isDark,
              ).animate(delay: 200.ms).fadeIn(duration: 450.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 16),

              // Worker card
              _RoleCard(
                emoji: '🔧',
                title: l10n.worker,
                description: l10n.workerDesc,
                accentColor: AppTheme.secondary,
                gradientColors: isDark
                    ? [const Color(0xFF2D1506), const Color(0xFF1E0D04)]
                    : [const Color(0xFFFFF0EB), const Color(0xFFFFF5F0)],
                badgeLabel: 'WORKER',
                onTap: () => context.push('/login/provider'),
                isDark: isDark,
              ).animate(delay: 350.ms).fadeIn(duration: 450.ms).slideY(begin: 0.15, end: 0),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String emoji, title, description, badgeLabel;
  final Color accentColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isDark;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.gradientColors,
    required this.badgeLabel,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.accentColor.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji in styled box
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(widget.emoji, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.badgeLabel,
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: widget.accentColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
