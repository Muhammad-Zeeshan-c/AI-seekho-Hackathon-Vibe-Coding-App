import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/log_service.dart';

/// Screen allowing clients to file reports for safety or financial anomalies
class ReportScreen extends StatefulWidget {
  final String bookingId;
  final String providerId;
  const ReportScreen({super.key, required this.bookingId, required this.providerId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _detailsController = TextEditingController();
  final List<String> _reasons = [
    'Worker requested advance/upfront payment',
    'Worker demanded extra cash above estimate',
    'Worker did not show up at schedule',
    'Mismatched profile name/photo in real life',
    'Inappropriate language or behavior',
    'Offered deals outside KaamKaar platform',
  ];
  final List<String> _selectedReasons = [];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (_selectedReasons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one reason / وجہ منتخب کریں')),
      );
      return;
    }

    await LogService.logEvent('COMPLIANCE_REPORT_FILED', {
      'booking_id': widget.bookingId,
      'provider_id': widget.providerId,
      'reasons': _selectedReasons,
      'details': _detailsController.text,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report filed! Support team will review. / رپورٹ درج ہو گئی ہے')),
      );
      context.go('/dashboard/user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('⚠️ Report Scam / Complaint'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Security tip warning box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.errorRed.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.security_rounded, color: AppTheme.errorRed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KaamKaar Security Protocol',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.errorRed, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Never send advance money in EasyPaisa/JazzCash before service completion. Report any suspicious requests below.',
                            style: TextStyle(color: AppTheme.errorRed.withOpacity(0.9), fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Select Violation Reason(s)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Checklist of violations
              Column(
                children: _reasons.map((reason) {
                  final isSelected = _selectedReasons.contains(reason);
                  return CheckboxListTile(
                    title: Text(reason, style: const TextStyle(fontSize: 13)),
                    value: isSelected,
                    activeColor: AppTheme.errorRed,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedReasons.add(reason);
                        } else {
                          _selectedReasons.remove(reason);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Text descriptions
              const Text('Add Details / تفصیلات لکھیں', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _detailsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe exactly what happened...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // CTA
              ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                  foregroundColor: Colors.white,
                ),
                child: const Text('File Scam Report / رپورٹ درج کریں'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
