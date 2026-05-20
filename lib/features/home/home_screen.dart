import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_ai_sekho_project/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_notifier.dart';
import '../../data/mock/mock_providers.dart';
import '../../data/models/provider_model.dart';

/// Client home screen — Uber-inspired, GPS-first, instant booking
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  // Service categories with emoji and names
  static const _services = [
    {'emoji': '⚡', 'label': 'Electrician', 'category': 'Electrician'},
    {'emoji': '🔧', 'label': 'Plumber', 'category': 'Plumber'},
    {'emoji': '❄️', 'label': 'AC Tech', 'category': 'AC Technician'},
    {'emoji': '🪚', 'label': 'Carpenter', 'category': 'Carpenter'},
    {'emoji': '🖌️', 'label': 'Painter', 'category': 'Painter'},
    {'emoji': '📚', 'label': 'Tutor', 'category': 'Tutor'},
    {'emoji': '💄', 'label': 'Beautician', 'category': 'Beautician'},
    {'emoji': '🚗', 'label': 'Driver', 'category': 'Driver'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeNotifierProvider);
    final topProviders = MockProviderDatabase.providers.where((p) => p.rating >= 4.7).take(6).toList();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: CustomScrollView(
        slivers: [
          // Premium SliverAppBar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.surface(context),
            elevation: 0,
            scrolledUnderElevation: 0,
            expandedHeight: 0,
            toolbarHeight: 64,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: AppTheme.surface(context)),
            ),
            title: _buildAppBarTitle(context, isDark),
            actions: [
              // Dark mode toggle
              GestureDetector(
                onTap: () => ref.read(themeNotifierProvider.notifier).toggle(context),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                    size: 18,
                    color: isDark ? Colors.amber : AppTheme.textSecondaryDark,
                  ),
                ),
              ),
              // Notifications
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.notifications_outlined, size: 20, color: AppTheme.textPrimary(context)),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.errorRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting + location section
                _buildGreetingSection(context, isDark),

                // AI Chat CTA — glowing pulsing button (CORE FEATURE)
                _buildAiChatCTA(context, isDark),

                const SizedBox(height: 28),

                // Services grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.services, style: Theme.of(context).textTheme.titleLarge),
                      GestureDetector(
                        onTap: () => context.push('/results?category=All'),
                        child: Text(
                          l10n.seeAll,
                          style: TextStyle(
                            color: isDark ? AppTheme.primaryDark : AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                _buildServiceGrid(context, isDark),

                const SizedBox(height: 28),

                // Top rated providers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.topRatedNearby, style: Theme.of(context).textTheme.titleLarge),
                      GestureDetector(
                        onTap: () => context.push('/results?category=All'),
                        child: Text(
                          l10n.seeAll,
                          style: TextStyle(
                            color: isDark ? AppTheme.primaryDark : AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                _buildTopRatedRow(context, isDark, topProviders),

                const SizedBox(height: 28),

                // Trust strip
                _buildTrustStrip(context, isDark),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      // Bottom nav
      bottomNavigationBar: _buildBottomNav(context, isDark),
      // FAB for AI chat
      floatingActionButton: _buildFAB(context, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppBarTitle(BuildContext context, bool isDark) {
    return Row(
      children: [
        // KaamKaar logo
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('⚡', style: TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'KaamKaar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary(context),
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 10, color: isDark ? AppTheme.primaryDark : AppTheme.primary),
                const SizedBox(width: 2),
                Text(
                  'G-13, Islamabad',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreetingSection(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF0D1F3C), Color(0xFF111827)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFE8F4FF), Color(0xFFF0F8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.primaryDark.withOpacity(0.2) : AppTheme.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assalam-o-Alaikum! 👋',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.whatDoYouNeed,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary(context),
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                // Location chip
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surface2Dark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.divider(context)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.my_location_rounded, size: 12, color: isDark ? AppTheme.primaryDark : AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'G-13, Islamabad',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.primaryDark : AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppTheme.textSecondary(context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Availability badge
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surface2Dark : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text('🏠', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '24 online',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAiChatCTA(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () => context.push('/ai-chat'),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A7FE8), Color(0xFF7C3AED)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(isDark ? 0.4 : 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // AI icon with pulse
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.aiAssistant,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppLocalizations.of(context)!.aiPromptHint,
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 2500.ms, color: Colors.white.withOpacity(0.1))
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildServiceGrid(BuildContext context, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _services.length,
      itemBuilder: (context, i) {
        final svc = _services[i];
        return GestureDetector(
          onTap: () => context.push('/results?category=${svc['category']}'),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.divider(context), width: 0.5),
                  boxShadow: isDark
                      ? []
                      : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Center(child: Text(svc['emoji']!, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(height: 6),
              Text(
                svc['label']!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ],
          ),
        ).animate(delay: (50 * i).ms).fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
      },
    );
  }

  Widget _buildTopRatedRow(BuildContext context, bool isDark, List<ProviderModel> providers) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: providers.length,
        itemBuilder: (context, i) {
          final p = providers[i];
          return GestureDetector(
            onTap: () => context.push('/provider/${p.id}'),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.divider(context), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with online ring
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: isDark ? AppTheme.primaryDark.withOpacity(0.2) : AppTheme.primary.withOpacity(0.1),
                        child: Text(
                          p.name[0],
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: isDark ? AppTheme.primaryDark : AppTheme.primary,
                          ),
                        ),
                      ),
                      if (p.verified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.surface(context), width: 1.5),
                            ),
                            child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.name.split(' ').first,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.category,
                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                      const SizedBox(width: 2),
                      Text(
                        p.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate(delay: (80 * i).ms).fadeIn(duration: 350.ms).slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }

  Widget _buildTrustStrip(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why KaamKaar?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          ...[
            ('✅', 'CNIC Verified Workers', 'Every worker has verified national ID'),
            ('⚡', 'Request in 60 Seconds', 'Instant AI-powered matching'),
            ('🔒', 'Safe & Secure', 'Insured services with quality guarantee'),
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$2, style: Theme.of(context).textTheme.titleSmall),
                        Text(item.$3, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        border: Border(top: BorderSide(color: AppTheme.divider(context), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 1) context.push('/history');
          if (i == 3) context.push('/logs');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: isDark ? AppTheme.primaryDark : AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary(context),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home_filled), label: AppLocalizations.of(context)!.home),
          BottomNavigationBarItem(icon: const Icon(Icons.receipt_long_outlined), activeIcon: const Icon(Icons.receipt_long_rounded), label: AppLocalizations.of(context)!.bookings),
          BottomNavigationBarItem(icon: const Icon(Icons.chat_bubble_outline_rounded), activeIcon: const Icon(Icons.chat_bubble_rounded), label: AppLocalizations.of(context)!.chat),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline_rounded), activeIcon: const Icon(Icons.person_rounded), label: AppLocalizations.of(context)!.profile),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/ai-chat'),
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}
