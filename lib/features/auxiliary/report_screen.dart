import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Screen to report a provider or issue
class ReportScreen extends StatefulWidget {
  final String providerId;
  const ReportScreen({super.key, required this.providerId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedReason;
  final _detailsController = TextEditingController();
  bool _submitted = false;

  final List<String> _reasons = [
    'Unprofessional behavior',
    'Did not show up',
    'Poor quality of work',
    'Asked for extra money',
    'Inappropriate language',
    'Other',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a reason'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_submitted) {
      return Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.shield_rounded, color: AppTheme.accent, size: 40)),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                Text('Report Submitted', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  'Our trust and safety team will review your report within 24 hours. We take these matters seriously.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
        title: Text('Report Issue', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTheme.errorRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Reporting provider ${widget.providerId}. All reports are confidential.',
                              style: const TextStyle(color: AppTheme.errorRed, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Why are you reporting?', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ..._reasons.map((reason) {
                      final isSelected = _selectedReason == reason;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedReason = reason),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? (isDark ? AppTheme.primaryDark.withOpacity(0.15) : AppTheme.primary.withOpacity(0.08)) : AppTheme.surface(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? (isDark ? AppTheme.primaryDark : AppTheme.primary) : AppTheme.divider(context),
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? (isDark ? AppTheme.primaryDark : AppTheme.primary) : AppTheme.textSecondary(context),
                                    width: isSelected ? 6 : 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(reason, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: AppTheme.textPrimary(context))),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Text('Additional Details', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Please provide more details about the incident...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(color: AppTheme.surface(context), border: Border(top: BorderSide(color: AppTheme.divider(context), width: 0.5))),
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                child: const Text('Submit Report', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
