import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_notifier.dart';
import 'package:new_ai_sekho_project/l10n/app_localizations.dart';

/// Premium worker dashboard — Uber Driver-style with online/offline toggle,
/// incoming request with countdown ring, earnings, and weekly stats.
class WorkerDashboard extends ConsumerStatefulWidget {
  const WorkerDashboard({super.key});

  @override
  ConsumerState<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends ConsumerState<WorkerDashboard> with SingleTickerProviderStateMixin {
  bool _isOnline = true;
  bool _hasIncomingRequest = true;
  int _countdownSeconds = 30;
  Timer? _requestTimer;
  late AnimationController _ringController;

  static const double _todayEarnings = 4800.0;
  static const double _weeklyTarget = 30000.0;
  static const double _weeklyEarned = 22400.0;

  // Mock weekly data for mini chart
  static const _weekData = [2800.0, 3500.0, 4200.0, 2900.0, 3800.0, 4100.0, 4800.0];
  static const _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(duration: const Duration(seconds: 30), vsync: this);
    _startRequestTimer();
  }

  @override
  void dispose() {
    _requestTimer?.cancel();
    _ringController.dispose();
    super.dispose();
  }

  void _startRequestTimer() {
    _ringController.forward();
    _requestTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
        setState(() => _hasIncomingRequest = false);
        _ringController.reset();
      }
    });
  }

  void _acceptRequest() {
    _requestTimer?.cancel();
    setState(() => _hasIncomingRequest = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Request Accepted! Navigate to client.', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppTheme.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.surface(context),
            toolbarHeight: 64,
            title: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('🔧', style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('KaamKaar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context))),
                    Text(l10n.urdu == 'اردو' ? 'ورکر پورٹل' : 'Worker Portal', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                  ],
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () => ref.read(themeNotifierProvider.notifier).toggle(context),
                child: Container(
                  width: 40, height: 40,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(12)),
                  child: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded, size: 18, color: isDark ? Colors.amber : AppTheme.textSecondaryDark),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/logs'),
                child: Container(
                  width: 40, height: 40,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.terminal_rounded, size: 18, color: AppTheme.aiPurple),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Online/Offline card
                  _buildOnlineCard(context, isDark, l10n).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  // Incoming request (if any)
                  if (_hasIncomingRequest && _isOnline)
                    _buildIncomingRequest(context, isDark, l10n).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

                  if (_hasIncomingRequest && _isOnline) const SizedBox(height: 16),

                  // Today's earnings
                  _buildEarningsCard(context, isDark, l10n).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  // Weekly chart
                  _buildWeeklyChart(context, isDark, l10n).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  // Quick stats
                  _buildQuickStats(context, isDark, l10n).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom nav
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          border: Border(top: BorderSide(color: AppTheme.divider(context), width: 0.5)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: isDark ? AppTheme.primaryDark : AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary(context),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: l10n.urdu == 'اردو' ? 'ڈیش بورڈ' : 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: l10n.bookings),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), activeIcon: Icon(Icons.bar_chart_rounded), label: l10n.earnings),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: l10n.profile),
          ],
          onTap: (i) { if (i == 1) context.push('/history'); },
          currentIndex: 0,
        ),
      ),
    );
  }

  Widget _buildOnlineCard(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _isOnline
            ? const LinearGradient(colors: [Color(0xFF00C896), Color(0xFF00A87A)], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : LinearGradient(colors: [isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF0F2F5), isDark ? const Color(0xFF111111) : Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _isOnline ? [BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))] : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? (l10n.urdu == 'اردو' ? 'آپ آن لائن ہیں 🟢' : 'You\'re ONLINE 🟢') : (l10n.urdu == 'اردو' ? 'آپ آف لائن ہیں ⚫' : 'You\'re OFFLINE ⚫'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18,
                    color: _isOnline ? Colors.white : AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isOnline 
                      ? (l10n.urdu == 'اردو' ? 'جی-۱۳ اور قریبی علاقوں میں درخواستیں وصول کر رہے ہیں' : 'Receiving requests in G-13 & nearby areas')
                      : (l10n.urdu == 'اردو' ? 'درخواستیں موصول کرنے کے لیے آن کریں' : 'Turn on to start receiving job requests'),
                  style: TextStyle(color: _isOnline ? Colors.white.withOpacity(0.8) : AppTheme.textSecondary(context), fontSize: 13),
                ),
              ],
            ),
          ),
          // Toggle switch
          GestureDetector(
            onTap: () {
              setState(() {
                _isOnline = !_isOnline;
                if (_isOnline) {
                  setState(() {
                    _hasIncomingRequest = true;
                    _countdownSeconds = 30;
                  });
                  _startRequestTimer();
                } else {
                  _requestTimer?.cancel();
                  _hasIncomingRequest = false;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                color: _isOnline ? Colors.white.withOpacity(0.25) : AppTheme.divider(context),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Align(
                alignment: _isOnline ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.white : AppTheme.textSecondary(context),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequest(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppTheme.primaryDark.withOpacity(0.4) : AppTheme.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.08), blurRadius: 16, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(l10n.urdu == 'اردو' ? 'نئی درخواست' : 'NEW REQUEST', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ],
                ),
              ),
              const Spacer(),
              // Countdown ring
              SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _ringController,
                      builder: (context, child) => CircularProgressIndicator(
                        value: _countdownSeconds / 30.0,
                        strokeWidth: 3,
                        backgroundColor: AppTheme.divider(context),
                        valueColor: AlwaysStoppedAnimation<Color>(_countdownSeconds > 10 ? AppTheme.primary : AppTheme.errorRed),
                      ),
                    ),
                    Text(
                      '$_countdownSeconds',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _countdownSeconds > 10 ? AppTheme.primary : AppTheme.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Request details
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
                child: const Text('M', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Muhammad Ali', style: Theme.of(context).textTheme.titleMedium),
                    Text('AC Split Service · 3.2 km away', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text('Rs. 1,800', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.accent, fontSize: 14)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Accept / Decline buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _requestTimer?.cancel();
                    setState(() => _hasIncomingRequest = false);
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(l10n.decline, style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textSecondary(context)))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _acceptRequest,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Center(child: Text(l10n.urdu == 'اردو' ? 'درخواست قبول کریں ✓' : 'Accept Request ✓', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.urdu == 'اردو' ? 'آج کی آمدنی' : 'Today\'s Earnings', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${_todayEarnings.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 32, color: isDark ? AppTheme.primaryDark : AppTheme.primary, letterSpacing: -0.5),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.trending_up_rounded, size: 14, color: AppTheme.accent),
                    const SizedBox(width: 4),
                    Text('+12%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 14, color: AppTheme.textSecondary(context)),
              const SizedBox(width: 6),
              Text(l10n.urdu == 'اردو' ? 'آج ۳ کام مکمل کیے' : '3 jobs completed today', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, bool isDark, AppLocalizations l10n) {
    final maxVal = _weekData.reduce(math.max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.urdu == 'اردو' ? 'اس ہفتے' : 'This Week', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                'Rs. ${_weeklyEarned.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? AppTheme.primaryDark : AppTheme.primary),
              ),
            ],
          ),
          Text(l10n.urdu == 'اردو' ? 'ہدف: روپے ${_weeklyTarget.toStringAsFixed(0)}' : 'Target: Rs. ${_weeklyTarget.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),

          // Bar chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_weekData.length, (i) {
              final isToday = i == _weekData.length - 1;
              final barHeight = (_weekData[i] / maxVal) * 80;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400 + i * 50),
                    width: 30,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: isToday ? AppTheme.primaryGradient : null,
                      color: isToday ? null : (isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weekDays[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                      color: isToday ? (isDark ? AppTheme.primaryDark : AppTheme.primary) : AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: _StatCard('4.8 ⭐', l10n.urdu == 'اردو' ? 'آپ کی ریٹنگ' : 'Your Rating', Icons.star_rounded, AppTheme.secondary, context, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard('98%', l10n.urdu == 'اردو' ? 'شرح قبولیت' : 'Acceptance', Icons.check_circle_rounded, AppTheme.accent, context, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard('140', l10n.urdu == 'اردو' ? 'کل کام' : 'Total Jobs', Icons.work_rounded, AppTheme.primary, context, isDark)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  final BuildContext context;
  final bool isDark;

  const _StatCard(this.value, this.label, this.icon, this.color, this.context, this.isDark);

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.textPrimary(context))),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
