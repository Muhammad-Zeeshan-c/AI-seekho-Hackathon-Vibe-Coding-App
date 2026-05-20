import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

/// Premium login screen for both clients and workers.
/// Uses phone number auth (Firebase OTP in Phase 2).
class LoginScreen extends StatefulWidget {
  final String initialRole; // "user" or "provider"
  const LoginScreen({super.key, required this.initialRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialRole == 'provider' ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Validates and navigates to appropriate dashboard (Phase 2: real OTP)
  void _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    // Phase 1: direct login — Phase 2 will send OTP via Firebase Phone Auth
    final role = _tabController.index == 0 ? 'user' : 'provider';
    context.go('/dashboard/$role');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back button
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider(context)),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  l10n.welcomeBack,
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 6),

                Text(
                  l10n.loginToContinue,
                  style: Theme.of(context).textTheme.bodyLarge,
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // Role Tab Bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: isDark ? AppTheme.primaryDark : AppTheme.primary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: isDark ? Colors.black : Colors.white,
                    unselectedLabelColor: AppTheme.textSecondary(context),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: l10n.client),
                      Tab(text: l10n.worker),
                    ],
                  ),
                ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                // Phone Number Field
                Text(
                  l10n.phoneNumber,
                  style: Theme.of(context).textTheme.titleSmall,
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 8),

                // Custom phone field with +92 prefix
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: '3001234567',
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppTheme.divider(context), width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇵🇰', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            '+92',
                            style: TextStyle(
                              color: AppTheme.textPrimary(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter your phone number';
                    if (val.length < 10) return 'Enter a valid 10-digit Pakistani number';
                    return null;
                  },
                ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 36),

                // Continue Button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isLoading
                      ? Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _continue,
                          child: Text(l10n.continueButton),
                        ),
                ).animate(delay: 350.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
