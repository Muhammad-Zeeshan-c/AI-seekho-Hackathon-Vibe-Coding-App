import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Multi-step registration screen for both clients and workers.
/// Worker registration has additional steps for profile and services.
class RegisterScreen extends StatefulWidget {
  final String role; // "user" or "provider"
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _bioController = TextEditingController();

  // Worker-specific
  final List<String> _selectedCategories = [];
  double _serviceRadius = 8;
  int _experienceYears = 1;
  double _rateAmount = 1500;
  String _rateType = 'fixed';
  String _selectedCity = 'Islamabad';

  // Available service categories
  static const _categories = [
    {'icon': '⚡', 'name': 'Electrician'},
    {'icon': '🔧', 'name': 'Plumber'},
    {'icon': '❄️', 'name': 'AC Technician'},
    {'icon': '🪚', 'name': 'Carpenter'},
    {'icon': '🖌️', 'name': 'Painter'},
    {'icon': '📚', 'name': 'Tutor'},
    {'icon': '💄', 'name': 'Beautician'},
    {'icon': '🚗', 'name': 'Driver'},
    {'icon': '🌿', 'name': 'Gardener'},
    {'icon': '🧹', 'name': 'Cleaner'},
  ];

  static const _cities = ['Islamabad', 'Lahore', 'Karachi', 'Rawalpindi', 'Peshawar', 'Quetta'];

  bool get _isWorker => widget.role == 'provider';
  int get _totalSteps => _isWorker ? 3 : 1;

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _register();
    }
  }

  void _previous() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go('/dashboard/${widget.role == "provider" ? "provider" : "user"}');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back + step indicator
            _buildHeader(isDark),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _isWorker
                    ? [
                        _buildBasicInfoStep(isDark),
                        _buildServicesStep(isDark),
                        _buildRatesStep(isDark),
                      ]
                    : [_buildBasicInfoStep(isDark)],
              ),
            ),

            // Bottom button
            _buildBottomButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _previous,
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
              const Spacer(),
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Step progress bar
          if (_totalSteps > 1) ...[
            Row(
              children: List.generate(_totalSteps, (i) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? (isDark ? AppTheme.primaryDark : AppTheme.primary)
                          : (isDark ? AppTheme.surface2Dark : const Color(0xFFEEEEEE)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            _isWorker ? 'Your Details' : 'Create Account',
            style: Theme.of(context).textTheme.displayMedium,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 6),
          Text(
            _isWorker ? 'Tell clients who you are' : 'Get started with KaamKaar',
            style: Theme.of(context).textTheme.bodyLarge,
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 28),

          // Name field
          _SectionLabel('Full Name', context),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'e.g. Ali Hassan',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Phone field
          _SectionLabel('Phone Number', context),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            decoration: InputDecoration(
              hintText: '3001234567',
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇵🇰', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text('+92 ', style: TextStyle(color: AppTheme.textPrimary(context), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

          if (_isWorker) ...[
            const SizedBox(height: 20),

            // CNIC field (worker only)
            _SectionLabel('CNIC Number', context),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cnicController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(13)],
              decoration: const InputDecoration(
                hintText: '3520212345678',
                prefixIcon: Icon(Icons.badge_outlined),
                helperText: '13-digit CNIC without dashes',
              ),
            ).animate(delay: 250.ms).fadeIn(duration: 300.ms),
          ],

          const SizedBox(height: 20),

          // City selector
          _SectionLabel('Your City', context),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppTheme.dividerDark : Colors.transparent),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_city_outlined),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              dropdownColor: AppTheme.surface(context),
              items: _cities
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: TextStyle(color: AppTheme.textPrimary(context))),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCity = val ?? 'Islamabad'),
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildServicesStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Your Services', style: Theme.of(context).textTheme.displayMedium)
              .animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 6),
          Text('Select all services you provide', style: Theme.of(context).textTheme.bodyLarge)
              .animate(delay: 100.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 24),

          // Service category grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.4,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final isSelected = _selectedCategories.contains(cat['name']);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCategories.remove(cat['name']);
                    } else {
                      _selectedCategories.add(cat['name']!);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppTheme.primaryDark.withOpacity(0.2) : AppTheme.primary.withOpacity(0.08))
                        : AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.divider(context),
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(cat['icon']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat['name']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppTheme.primary : AppTheme.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 28),

          // Experience years
          _SectionLabel('Years of Experience: $_experienceYears years', context),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.divider(context),
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: _experienceYears.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              onChanged: (val) => setState(() => _experienceYears = val.round()),
            ),
          ).animate(delay: 250.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildRatesStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Rates & Availability', style: Theme.of(context).textTheme.displayMedium)
              .animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 6),
          Text('Set your pricing and service area', style: Theme.of(context).textTheme.bodyLarge)
              .animate(delay: 100.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 28),

          // Rate type toggle
          _SectionLabel('Rate Type', context),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _rateType = 'fixed'),
                  child: _RateTypeCard(
                    label: 'Fixed Rate',
                    sublabel: 'Per visit/job',
                    icon: Icons.work_outline_rounded,
                    isSelected: _rateType == 'fixed',
                    isDark: isDark,
                    context: context,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _rateType = 'hourly'),
                  child: _RateTypeCard(
                    label: 'Hourly Rate',
                    sublabel: 'Per hour',
                    icon: Icons.schedule_rounded,
                    isSelected: _rateType == 'hourly',
                    isDark: isDark,
                    context: context,
                  ),
                ),
              ),
            ],
          ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Rate amount slider
          _SectionLabel(
            'Amount: PKR ${_rateAmount.round()} ${_rateType == 'hourly' ? '/hr' : '/visit'}',
            context,
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.divider(context),
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: _rateAmount,
              min: 500,
              max: 10000,
              divisions: 19,
              onChanged: (val) => setState(() => _rateAmount = val),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Service radius
          _SectionLabel('Service Radius: ${_serviceRadius.round()} km', context),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.accent,
              inactiveTrackColor: AppTheme.divider(context),
              thumbColor: AppTheme.accent,
              overlayColor: AppTheme.accent.withOpacity(0.1),
            ),
            child: Slider(
              value: _serviceRadius,
              min: 2,
              max: 25,
              divisions: 23,
              onChanged: (val) => setState(() => _serviceRadius = val),
            ),
          ).animate(delay: 250.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Short bio
          _SectionLabel('Short Bio (optional)', context),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bioController,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: 'Tell clients about yourself and your experience...',
              alignLabelWithHint: true,
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildBottomButton(bool isDark) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        border: Border(top: BorderSide(color: AppTheme.divider(context), width: 0.5)),
      ),
      child: AnimatedSwitcher(
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
                    child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: _next,
                child: Text(isLastStep ? 'Create Account' : 'Continue'),
              ),
      ),
    );
  }
}

/// Helper section label widget
class _SectionLabel extends StatelessWidget {
  final String text;
  final BuildContext context;
  const _SectionLabel(this.text, this.context);

  @override
  Widget build(BuildContext _) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}

/// Rate type selection card
class _RateTypeCard extends StatelessWidget {
  final String label, sublabel;
  final IconData icon;
  final bool isSelected, isDark;
  final BuildContext context;

  const _RateTypeCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppTheme.primaryDark.withOpacity(0.15) : AppTheme.primary.withOpacity(0.06))
            : AppTheme.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.divider(context),
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary(context), size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppTheme.primary : AppTheme.textPrimary(context),
            ),
          ),
          Text(
            sublabel,
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context)),
          ),
        ],
      ),
    );
  }
}
