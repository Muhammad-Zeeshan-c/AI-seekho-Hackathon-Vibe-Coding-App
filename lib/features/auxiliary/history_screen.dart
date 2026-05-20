import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Screen listing booking records and transaction history
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock History
    final List<Map<String, dynamic>> mockBookings = [
      {
        'id': 'BK-A9F21',
        'providerName': 'Muhammad Usman',
        'providerId': 'PRV-001',
        'service': 'Electrician (Fan installation)',
        'date': 'Today',
        'slot': '12:00 PM',
        'status': 'en_route',
        'cost': 'PKR 1,200',
      },
      {
        'id': 'BK-Z2810',
        'providerName': 'Ali Butt',
        'providerId': 'PRV-002',
        'service': 'Plumber (Pipe Fitting)',
        'date': 'Yesterday',
        'slot': '3:00 PM',
        'status': 'completed',
        'cost': 'PKR 1,500',
      },
      {
        'id': 'BK-M1150',
        'providerName': 'Sara Khan',
        'providerId': 'PRV-007',
        'service': 'Beautician (Party Makeup)',
        'date': 'May 14, 2026',
        'slot': '11:00 AM',
        'status': 'completed',
        'cost': 'PKR 3,500',
      },
      {
        'id': 'BK-C2001',
        'providerName': 'Hassan Abbasi',
        'providerId': 'PRV-015',
        'service': 'AC Tech (Compressor Check)',
        'date': 'May 10, 2026',
        'slot': '4:00 PM',
        'status': 'cancelled',
        'cost': 'PKR 0',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Booking History / تاریخچہ'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockBookings.length,
        itemBuilder: (context, index) {
          final b = mockBookings[index];
          final status = b['status'] as String;
          
          Color badgeColor = Colors.grey;
          String statusText = status.toUpperCase();
          if (status == 'en_route') {
            badgeColor = AppTheme.primary;
            statusText = 'EN ROUTE';
          } else if (status == 'completed') {
            badgeColor = AppTheme.accent;
            statusText = 'COMPLETED';
          } else if (status == 'cancelled') {
            badgeColor = AppTheme.errorRed;
            statusText = 'CANCELLED';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        b['id'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    b['providerName'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b['service'] as String,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${b['date']} at ${b['slot']}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        b['cost'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary),
                      ),
                      if (status == 'en_route')
                        ElevatedButton(
                          onPressed: () {
                            context.push('/tracking?bookingId=${b['id']}&providerId=${b['providerId']}');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Track Live'),
                        )
                      else if (status == 'completed')
                        OutlinedButton(
                          onPressed: () {
                            context.push('/feedback/${b['id']}');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Rate Job'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
