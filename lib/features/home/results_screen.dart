import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_providers.dart';
import '../../data/models/provider_model.dart';

/// Results / provider listing screen — on-demand, no time slots
class ResultsScreen extends StatefulWidget {
  final String category;
  const ResultsScreen({super.key, required this.category});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _sortBy = 'Rating';
  bool _onlyVerified = false;
  late List<ProviderModel> _providers;

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    var list = MockProviderDatabase.providers.where((p) {
      if (widget.category != 'All' && widget.category.isNotEmpty) {
        return p.category.toLowerCase().contains(widget.category.toLowerCase());
      }
      return true;
    }).toList();

    if (_onlyVerified) list = list.where((p) => p.verified).toList();

    switch (_sortBy) {
      case 'Rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 'Price':
        list.sort((a, b) => a.rateAmount.compareTo(b.rateAmount));
      case 'Distance':
        list.sort((a, b) => a.lat.compareTo(b.lat)); // mock distance sort
    }
    _providers = list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppTheme.textPrimary(context)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category.isEmpty || widget.category == 'All' ? 'All Services' : widget.category,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${_providers.length} providers available now',
              style: TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/ai-chat'),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
            ),
            tooltip: 'Ask AI',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter / sort bar
          _buildFilterBar(context, isDark),

          // Provider list
          Expanded(
            child: _providers.isEmpty
                ? _buildEmptyState(context, isDark)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _providers.length,
                    itemBuilder: (context, i) {
                      return _ProviderCard(
                        provider: _providers[i],
                        isTopPick: i == 0,
                        isDark: isDark,
                        onTap: () => context.push('/provider/${_providers[i].id}'),
                        onBook: () => context.push('/booking/confirm?providerId=${_providers[i].id}'),
                      ).animate(delay: (60 * i).ms).fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, bool isDark) {
    return Container(
      color: AppTheme.surface(context),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        children: [
          // Sort chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text('Sort:', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                ...['Rating', 'Price', 'Distance'].map((sort) {
                  final isSelected = _sortBy == sort;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _sortBy = sort;
                      _applyFilters();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppTheme.primaryDark : AppTheme.primary)
                            : (isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sort,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? (isDark ? Colors.black : Colors.white) : AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 4),
                // Verified toggle
                GestureDetector(
                  onTap: () => setState(() {
                    _onlyVerified = !_onlyVerified;
                    _applyFilters();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _onlyVerified ? AppTheme.accent.withOpacity(0.15) : (isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _onlyVerified ? AppTheme.accent : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: _onlyVerified ? AppTheme.accent : AppTheme.textSecondary(context)),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _onlyVerified ? AppTheme.accent : AppTheme.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('😔', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No providers found', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Try a different category or\nremove filters',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() {
              _onlyVerified = false;
              _applyFilters();
            }),
            style: ElevatedButton.styleFrom(minimumSize: const Size(160, 46)),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}

/// Premium provider card with all trust signals
class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final bool isTopPick, isDark;
  final VoidCallback onTap, onBook;

  const _ProviderCard({
    required this.provider,
    required this.isTopPick,
    required this.isDark,
    required this.onTap,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    // Mock ETA calculation based on coordinates
    final etaMin = ((provider.lat - 33.68).abs() * 80 + 8).round().clamp(5, 45);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isTopPick ? AppTheme.primary.withOpacity(0.3) : AppTheme.divider(context),
            width: isTopPick ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            // AI top pick ribbon
            if (isTopPick)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    const Text(
                      'AI Recommended · Best match for your request',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: isDark ? AppTheme.primaryDark.withOpacity(0.2) : AppTheme.primary.withOpacity(0.1),
                            child: Text(
                              provider.name[0],
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                color: isDark ? AppTheme.primaryDark : AppTheme.primary,
                              ),
                            ),
                          ),
                          if (provider.verified)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppTheme.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.surface(context), width: 1.5),
                                ),
                                child: const Icon(Icons.check_rounded, size: 11, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    provider.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (provider.verified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'CNIC ✓',
                                      style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${provider.category} · ${provider.yearsExperience} yrs exp',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            // Stats row
                            Row(
                              children: [
                                Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                const SizedBox(width: 3),
                                Text(
                                  provider.rating.toStringAsFixed(1),
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary(context)),
                                ),
                                Text(
                                  ' (${provider.reviewCount})',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 10),
                                Icon(Icons.work_outline_rounded, size: 13, color: AppTheme.textSecondary(context)),
                                const SizedBox(width: 3),
                                Text(
                                  '${provider.completedJobs} jobs',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Tags
                  SizedBox(
                    height: 26,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: provider.tags.map((tag) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Price + ETA + Book button
                  Row(
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs. ${provider.rateAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: isDark ? AppTheme.primaryDark : AppTheme.primary,
                            ),
                          ),
                          Text(
                            provider.rateType == 'hourly' ? '/hour' : '/visit',
                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context)),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // ETA badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.schedule_rounded, size: 13, color: AppTheme.accent),
                            const SizedBox(width: 4),
                            Text(
                              '~$etaMin min',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Book Now CTA
                      GestureDetector(
                        onTap: onBook,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.primaryDark : AppTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Request',
                            style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
