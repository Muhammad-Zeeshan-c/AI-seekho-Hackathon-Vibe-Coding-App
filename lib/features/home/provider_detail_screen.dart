import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_providers.dart';
import '../../data/models/provider_model.dart';

/// Full provider profile — tabbed: About | Reviews | Portfolio
class ProviderDetailScreen extends StatefulWidget {
  final String providerId;
  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProviderModel _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _provider = MockProviderDatabase.providers.firstWhere(
      (p) => p.id == widget.providerId,
      orElse: () => MockProviderDatabase.providers.first,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final etaMin = (((_provider.lat - 33.68).abs() * 80) + 8).round().clamp(5, 45);

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Collapsible header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.surface(context),
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
                child: GestureDetector(
                  onTap: () => context.push('/report?providerId=${_provider.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.flag_outlined, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient banner
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.aiPurple,
                          const Color(0xFF1A1A2E),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Provider avatar
                  Positioned(
                    bottom: 16,
                    left: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                              ),
                              child: Center(
                                child: Text(
                                  _provider.name[0],
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: Colors.white),
                                ),
                              ),
                            ),
                            if (_provider.verified)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                  child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_provider.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
                            Text(_provider.category, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                const SizedBox(width: 3),
                                Text('${_provider.rating}  · ${_provider.reviewCount} reviews', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab bar
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: isDark ? AppTheme.primaryDark : AppTheme.primary,
              indicatorWeight: 3,
              labelColor: isDark ? AppTheme.primaryDark : AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary(context),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: const [Tab(text: 'About'), Tab(text: 'Reviews'), Tab(text: 'Portfolio')],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutTab(context, isDark, etaMin),
            _buildReviewsTab(context, isDark),
            _buildPortfolioTab(context, isDark),
          ],
        ),
      ),
      // Sticky book button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          border: Border(top: BorderSide(color: AppTheme.divider(context), width: 0.5)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rs. ${_provider.rateAmount.toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: isDark ? AppTheme.primaryDark : AppTheme.primary),
                ),
                Text(_provider.rateType == 'hourly' ? 'per hour' : 'per visit', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.push('/booking/confirm?providerId=${_provider.id}'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flash_on_rounded, size: 18),
                    const SizedBox(width: 6),
                    const Text('Request Now'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context, bool isDark, int etaMin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip('⏱ ~$etaMin min away', AppTheme.accent, context, isDark),
              _InfoChip('💼 ${_provider.yearsExperience} yrs exp', AppTheme.primary, context, isDark),
              _InfoChip('✅ ${_provider.completedJobs} jobs done', AppTheme.secondary, context, isDark),
              if (_provider.verified) _InfoChip('🔒 CNIC Verified', AppTheme.accent, context, isDark),
            ],
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Bio
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider(context), width: 0.5),
            ),
            child: Text(_provider.bio, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Services
          Text('Services Offered', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _provider.subcategories.map((sub) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppTheme.primaryDark.withOpacity(0.3) : AppTheme.primary.withOpacity(0.2)),
                ),
                child: Text(sub, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppTheme.primaryDark : AppTheme.primary)),
              );
            }).toList(),
          ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Tags
          Text('Client Feedback Tags', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _provider.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context))),
              );
            }).toList(),
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Rating breakdown
          Text('Rating Breakdown', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider(context), width: 0.5),
            ),
            child: Row(
              children: [
                // Big rating number
                Column(
                  children: [
                    Text(
                      _provider.rating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: isDark ? AppTheme.primaryDark : AppTheme.primary),
                    ),
                    Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, size: 14, color: i < _provider.rating.round() ? Colors.amber : AppTheme.divider(context)))),
                    const SizedBox(height: 4),
                    Text('${_provider.reviewCount} reviews', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(width: 20),
                // Bars
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final frac = star == _provider.rating.round() ? 0.7 : (star > _provider.rating ? 0.1 : 0.4);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Text('$star', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
                            const SizedBox(width: 6),
                            const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: frac,
                                  minHeight: 6,
                                  backgroundColor: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ).animate(delay: 250.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _provider.reviews.length,
      itemBuilder: (context, i) {
        final review = _provider.reviews[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider(context), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
                    child: Text(review.reviewerName[0], style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textPrimary(context))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.reviewerName, style: Theme.of(context).textTheme.titleSmall),
                        Text(review.date, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (j) => Icon(j < review.rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 13, color: Colors.amber)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(review.comment, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
              if (review.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: review.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(tag, style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ],
            ],
          ),
        ).animate(delay: (60 * i).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildPortfolioTab(BuildContext context, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: 6,
      itemBuilder: (context, i) {
        final gradients = [
          [const Color(0xFF1A7FE8), const Color(0xFF7C3AED)],
          [const Color(0xFF00C896), const Color(0xFF1A7FE8)],
          [const Color(0xFFFF6B35), const Color(0xFFFF9500)],
          [const Color(0xFF7C3AED), const Color(0xFFEC4899)],
          [const Color(0xFF1A7FE8), const Color(0xFF00C896)],
          [const Color(0xFFFF6B35), const Color(0xFF7C3AED)],
        ];
        final emojis = ['⚡', '🔧', '❄️', '🛠️', '✅', '🏆'];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradients[i], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Center(child: Text(emojis[i], style: const TextStyle(fontSize: 40))),
              Positioned(
                bottom: 10,
                left: 10,
                child: Text(
                  'Job ${i + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        ).animate(delay: (80 * i).ms).fadeIn(duration: 350.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final BuildContext context;
  final bool isDark;

  const _InfoChip(this.label, this.color, this.context, this.isDark);

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
