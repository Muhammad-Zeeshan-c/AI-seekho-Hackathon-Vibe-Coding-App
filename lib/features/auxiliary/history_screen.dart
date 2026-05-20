import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/booking_model.dart';
import '../../data/mock/mock_providers.dart';
import 'package:new_ai_sekho_project/l10n/app_localizations.dart';

/// User/Worker History Screen showing Past, Active, and Cancelled bookings
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  final List<Map<String, dynamic>> _activeBookings = [
    {
      'id': 'KAK-2026-9482',
      'service': 'AC Split Service',
      'provider': 'Muhammad Ali',
      'date': 'Today, 2:30 PM',
      'amount': 1800,
      'status': 'En Route',
    }
  ];

  final List<Map<String, dynamic>> _pastBookings = [
    {
      'id': 'KAK-2026-1184',
      'service': 'Kitchen Tap Repair',
      'provider': 'Aisha K.',
      'date': 'May 18, 2026',
      'amount': 1200,
      'status': 'Completed',
    },
    {
      'id': 'KAK-2026-0921',
      'service': 'Ceiling Fan Wiring',
      'provider': 'Zainab Bibi',
      'date': 'May 15, 2026',
      'amount': 1500,
      'status': 'Completed',
    }
  ];

  final List<Map<String, dynamic>> _cancelledBookings = [
    {
      'id': 'KAK-2026-0042',
      'service': 'Wall Painting (1 Room)',
      'provider': 'Usman Khan',
      'date': 'May 10, 2026',
      'amount': 4500,
      'status': 'Cancelled',
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
        title: Text(l10n.urdu == 'اردو' ? 'میری بکنگز' : 'My Bookings', style: Theme.of(context).textTheme.titleLarge),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? AppTheme.primaryDark : AppTheme.primary,
          indicatorWeight: 3,
          labelColor: isDark ? AppTheme.primaryDark : AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary(context),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(text: l10n.urdu == 'اردو' ? 'فعال' : 'Active'),
            Tab(text: l10n.urdu == 'اردو' ? 'مکمل شدہ' : 'Completed'),
            Tab(text: l10n.urdu == 'اردو' ? 'منسوخ شدہ' : 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_activeBookings, isDark, l10n, isActive: true),
          _buildList(_pastBookings, isDark, l10n),
          _buildList(_cancelledBookings, isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> bookings, bool isDark, AppLocalizations l10n, {bool isActive = false}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textSecondary(context).withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(l10n.noHistory, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? (l10n.urdu == 'اردو' ? 'آپ کی کوئی فعال بکنگ نہیں ہے۔' : 'You have no active bookings.')
                  : (l10n.urdu == 'اردو' ? 'آپ کی کوئی پرانی بکنگ نہیں ہے۔' : 'You have no past bookings.'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(
          booking: booking,
          isDark: isDark,
          isActive: isActive,
          l10n: l10n,
          onTap: () {
            // Optionally navigate to details
          },
        ).animate(delay: (100 * index).ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isDark;
  final bool isActive;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.isDark,
    required this.isActive,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (booking['status'] == 'Completed') {
      statusColor = AppTheme.secondary;
    } else if (booking['status'] == 'Cancelled') {
      statusColor = AppTheme.errorRed;
    } else {
      statusColor = AppTheme.accent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking['id'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary(context))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking['status'] == 'Completed'
                        ? (l10n.urdu == 'اردو' ? 'مکمل شدہ' : 'Completed')
                        : booking['status'] == 'Cancelled'
                            ? (l10n.urdu == 'اردو' ? 'منسوخ شدہ' : 'Cancelled')
                            : (l10n.urdu == 'اردو' ? 'راستے میں ہے' : 'En Route'),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isDark ? AppTheme.primaryDark.withOpacity(0.2) : AppTheme.primary.withOpacity(0.1),
                  child: Text(
                    booking['provider'][0],
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? AppTheme.primaryDark : AppTheme.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking['service'], style: Theme.of(context).textTheme.titleSmall),
                      Text(booking['provider'], style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Rs. ${booking['amount']}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textPrimary(context))),
                    Text(l10n.urdu == 'اردو' ? 'کل رقم' : 'Total', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.textSecondary(context)),
                    const SizedBox(width: 6),
                    Text(booking['date'], style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                if (isActive)
                  GestureDetector(
                    onTap: () => context.push('/tracking?bookingId=${booking['id']}&providerId=PRV-001'),
                    child: Text(l10n.urdu == 'اردو' ? 'لائیو ٹریک کریں' : 'Track live', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.primaryDark : AppTheme.primary)),
                  )
                else if (booking['status'] == 'Completed')
                  GestureDetector(
                    onTap: () => context.push('/rating?bookingId=${booking['id']}'),
                    child: Text(l10n.rateService, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
