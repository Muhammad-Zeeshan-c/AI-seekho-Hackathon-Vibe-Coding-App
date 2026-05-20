import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_providers.dart';
import '../../data/models/provider_model.dart';
import 'package:new_ai_sekho_project/l10n/app_localizations.dart';

/// Instant booking confirmation — no time slot picker, on-demand like Uber.
/// Shows provider info → issue description → confirm → confetti success.
class BookingConfirmScreen extends StatefulWidget {
  final String providerId;
  const BookingConfirmScreen({super.key, required this.providerId});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  late ProviderModel _provider;
  late ConfettiController _confetti;
  final _notesController = TextEditingController();

  bool _isConfirmed = false;
  bool _isLoading = false;

  // Quick issue tags — user can tap instead of typing
  final List<String> _quickTags = [
    'Not working', 'Needs repair', 'Installation', 'Inspection', 'Maintenance', 'Emergency'
  ];
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _provider = MockProviderDatabase.providers.firstWhere(
      (p) => p.id == widget.providerId,
      orElse: () => MockProviderDatabase.providers.first,
    );
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isConfirmed = true;
    });
    _confetti.play();
  }

  String get _bookingId {
    final ts = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'KAK-2026-$ts';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Stack(
        children: [
          if (_isConfirmed)
            _buildSuccessScreen(context, isDark, l10n)
          else
            _buildBookingForm(context, isDark, l10n),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              colors: const [AppTheme.primary, AppTheme.accent, AppTheme.secondary, Colors.amber, Colors.white],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingForm(BuildContext context, bool isDark, AppLocalizations l10n) {
    final etaMin = (((_provider.lat - 33.68).abs() * 80) + 8).round().clamp(5, 45);

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
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider(context)),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppTheme.textPrimary(context)),
                  ),
                ),
                const SizedBox(width: 14),
                Text(l10n.confirmBooking, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider summary card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.divider(context), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isDark ? AppTheme.primaryDark.withOpacity(0.2) : AppTheme.primary.withOpacity(0.1),
                          child: Text(
                            _provider.name[0],
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: isDark ? AppTheme.primaryDark : AppTheme.primary),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_provider.name, style: Theme.of(context).textTheme.titleMedium),
                              Text('${_provider.category} · ${_provider.yearsExperience} yrs', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                                  const SizedBox(width: 3),
                                  Text(_provider.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  if (_provider.verified) ...[
                                    Icon(Icons.verified_rounded, size: 13, color: AppTheme.accent),
                                    const SizedBox(width: 3),
                                    Text(l10n.cnicVerified, style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // ETA badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('~$etaMin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.accent)),
                              Text('min', style: TextStyle(fontSize: 10, color: AppTheme.accent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 20),

                  // Location — auto-filled
                  Text(l10n.yourLocation, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.divider(context), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.primaryDark.withOpacity(0.15) : AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.location_on_rounded, size: 18, color: isDark ? AppTheme.primaryDark : AppTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('G-13/4, Islamabad', style: Theme.of(context).textTheme.titleSmall),
                              Text('Your current location (auto-detected)', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Icon(Icons.edit_location_alt_outlined, size: 18, color: AppTheme.textSecondary(context)),
                      ],
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 20),

                  // Quick issue tags
                  Text(l10n.whatsTheIssue, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) _selectedTags.remove(tag); else _selectedTags.add(tag);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppTheme.primaryDark.withOpacity(0.2) : AppTheme.primary.withOpacity(0.1))
                                : AppTheme.surface(context),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : AppTheme.divider(context),
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? (isDark ? AppTheme.primaryDark : AppTheme.primary) : AppTheme.textPrimary(context),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 16),

                  // Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.urdu == 'اردو' ? 'کوئی خاص ہدایات؟ (مثلاً دوسری منزل، گھنٹی دو بار بجائیں)' : 'Any special instructions? (e.g. 2nd floor, ring bell twice)',
                      hintStyle: TextStyle(color: AppTheme.textSecondary(context), fontSize: 14),
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // Pricing summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.divider(context), width: 0.5),
                    ),
                    child: Column(
                      children: [
                        _PriceRow(l10n.serviceFee, 'Rs. ${_provider.rateAmount.toStringAsFixed(0)}', context, isDark),
                        const SizedBox(height: 8),
                        _PriceRow(l10n.platformFee, 'Rs. 50', context, isDark),
                        const Divider(height: 20),
                        _PriceRow(
                          l10n.estTotal,
                          'Rs. ${(_provider.rateAmount + 50).toStringAsFixed(0)}',
                          context, isDark,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ).animate(delay: 250.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 16, color: AppTheme.accent),
                      const SizedBox(width: 6),
                      Text(l10n.paymentCOD, style: TextStyle(fontSize: 13, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Confirm button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              border: Border(top: BorderSide(color: AppTheme.divider(context), width: 0.5)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isLoading
                  ? Container(
                      height: 52,
                      decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))),
                    )
                  : ElevatedButton(
                      onPressed: _confirmBooking,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flash_on_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.requestNow),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context, bool isDark, AppLocalizations l10n) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Success animation
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24, spreadRadius: 4)],
              ),
              child: const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 52)),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 24),

            Text(l10n.requestSent, style: Theme.of(context).textTheme.displayMedium)
                .animate(delay: 200.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 8),
             Text(
              l10n.urdu == 'اردو' ? 'ہم آپ کے لیے ${_provider.name} کو تلاش کر رہے ہیں۔\nجب وہ قبول کریں گے تو آپ کو مطلع کر دیا جائے گا۔' : 'We\'re finding ${_provider.name} for you.\nYou\'ll be notified when they accept.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // Booking card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppTheme.primaryDark.withOpacity(0.3) : AppTheme.primary.withOpacity(0.2), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.urdu == 'اردو' ? 'بکنگ آئی ڈی' : 'Booking ID', style: Theme.of(context).textTheme.bodySmall),
                      Text(_bookingId, style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? AppTheme.primaryDark : AppTheme.primary, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _BookingDetailRow(l10n.worker, _provider.name, context, isDark),
                  const SizedBox(height: 8),
                  _BookingDetailRow(l10n.services, _provider.category, context, isDark),
                  const SizedBox(height: 8),
                  _BookingDetailRow(l10n.urdu == 'اردو' ? 'لوکیشن' : 'Location', 'G-13/4, Islamabad', context, isDark),
                  const SizedBox(height: 8),
                  _BookingDetailRow(l10n.urdu == 'اردو' ? 'متوقع قیمت' : 'Est. Cost', 'Rs. ${(_provider.rateAmount + 50).toStringAsFixed(0)}', context, isDark),
                  const SizedBox(height: 8),
                  _BookingDetailRow(l10n.urdu == 'اردو' ? 'طریقہ ادائیگی' : 'Payment', l10n.urdu == 'اردو' ? 'کیش آن ڈیلیوری' : 'Cash on Delivery', context, isDark),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Track button
            ElevatedButton(
              onPressed: () => context.go('/tracking?bookingId=$_bookingId&providerId=${_provider.id}'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.trackingWorker),
                ],
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => context.go('/dashboard/user'),
              child: Text(l10n.home),
            ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final BuildContext context;
  final bool isDark, isTotal;

  const _PriceRow(this.label, this.value, this.context, this.isDark, {this.isTotal = false});

  @override
  Widget build(BuildContext _) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? Theme.of(context).textTheme.titleSmall : Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: isTotal
              ? TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? AppTheme.primaryDark : AppTheme.primary)
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _BookingDetailRow extends StatelessWidget {
  final String label, value;
  final BuildContext context;
  final bool isDark;

  const _BookingDetailRow(this.label, this.value, this.context, this.isDark);

  @override
  Widget build(BuildContext _) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
