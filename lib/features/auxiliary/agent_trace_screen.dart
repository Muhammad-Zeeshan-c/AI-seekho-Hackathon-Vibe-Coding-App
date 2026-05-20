import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/log_service.dart';

/// Screen to view agent action logs
class AgentTraceScreen extends StatefulWidget {
  const AgentTraceScreen({super.key});

  @override
  State<AgentTraceScreen> createState() => _AgentTraceScreenState();
}

class _AgentTraceScreenState extends State<AgentTraceScreen> {
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await LogService.getLogs();
    setState(() {
      _logs = logs.reversed.toList();
    });
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
        title: Row(
          children: [
            Icon(Icons.terminal_rounded, size: 20, color: AppTheme.aiPurple),
            const SizedBox(width: 8),
            Text('System Logs', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              LogService.clearLogs();
              _loadLogs();
            },
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: _logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terminal_rounded, size: 64, color: AppTheme.textSecondary(context).withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No logs available', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final level = log['type'] ?? 'INFO';
                final timestampStr = log['timestamp'] as String? ?? DateTime.now().toIso8601String();
                final timestamp = DateTime.parse(timestampStr);
                final message = (log['data'] ?? {}).toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D0D20) : const Color(0xFFF0EEFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.aiPurple.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            level,
                            style: AppTheme.monoStyle(
                              fontSize: 12,
                              color: level == 'ERROR' ? AppTheme.errorRed : AppTheme.aiPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
                            style: AppTheme.monoStyle(fontSize: 10, color: AppTheme.textSecondary(context)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: AppTheme.monoStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.textPrimaryDark : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
