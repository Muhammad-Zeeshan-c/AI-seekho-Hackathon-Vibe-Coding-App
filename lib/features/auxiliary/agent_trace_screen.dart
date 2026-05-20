import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/log_service.dart';

/// Terminal-style logs analyzer interface for developer diagnostics and AI observability
class AgentTraceScreen extends StatefulWidget {
  const AgentTraceScreen({super.key});

  @override
  State<AgentTraceScreen> createState() => _AgentTraceScreenState();
}

class _AgentTraceScreenState extends State<AgentTraceScreen> {
  List<Map<String, dynamic>> _logs = [];
  String _activeFilter = 'ALL';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() async {
    setState(() => _isLoading = true);
    final logs = await LogService.getLogs();
    setState(() {
      _logs = logs.reversed.toList(); // Newest first
      _isLoading = false;
    });
  }

  void _clearLogs() async {
    await LogService.clearLogs();
    _loadLogs();
  }

  List<Map<String, dynamic>> get _filteredLogs {
    if (_activeFilter == 'ALL') return _logs;
    return _logs.where((log) {
      final type = (log['type'] as String? ?? '').toLowerCase();
      if (_activeFilter == 'AI') {
        return type.startsWith('agent_') || type == 'scam_scanner_check';
      }
      if (_activeFilter == 'TRACKING') {
        return type.startsWith('tracking_');
      }
      if (_activeFilter == 'COMPLIANCE') {
        return type == 'compliance_report_filed';
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F141C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161E2E),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '⚙️ KaamKaar Telemetry Terminal',
            style: AppTheme.monoStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.cyan),
              onPressed: _loadLogs,
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
              onPressed: _clearLogs,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Chips Row
              _buildFilterBar(),

              // Terminal Logs Area
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredLogs.isEmpty
                        ? Center(
                            child: Text(
                              '-- No telemetry logs recorded --',
                              style: AppTheme.monoStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _filteredLogs.length,
                            itemBuilder: (context, index) {
                              final log = _filteredLogs[index];
                              return _buildTerminalLogItem(log);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['ALL', 'AI', 'TRACKING', 'COMPLIANCE'];
    return Container(
      color: const Color(0xFF161E2E),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: filters.map((f) {
          final isActive = _activeFilter == f;
          return ChoiceChip(
            label: Text(f, style: AppTheme.monoStyle(fontSize: 10, color: isActive ? Colors.black : Colors.white)),
            selected: isActive,
            selectedColor: const Color(0xFF00FF66),
            backgroundColor: const Color(0xFF1F2937),
            onSelected: (selected) {
              if (selected) setState(() => _activeFilter = f);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTerminalLogItem(Map<String, dynamic> log) {
    final timestamp = log['timestamp'] as String? ?? '';
    final timeStr = timestamp.contains('T') ? timestamp.split('T')[1].substring(0, 8) : '';
    final type = log['type'] as String? ?? 'SYSTEM';
    final data = log['data'] ?? {};
    
    // Choose telemetry token color
    Color typeColor = Colors.cyanAccent;
    if (type.startsWith('AGENT_')) {
      typeColor = const Color(0xFFA855F7); // purple
    } else if (type == 'COMPLIANCE_REPORT_FILED') {
      typeColor = Colors.redAccent;
    } else if (type.startsWith('TRACKING_')) {
      typeColor = Colors.greenAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2E3B4E)),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        iconColor: Colors.white54,
        collapsedIconColor: Colors.white30,
        title: Row(
          children: [
            Text(
              '[$timeStr]',
              style: AppTheme.monoStyle(fontSize: 11, color: Colors.white30),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                type,
                style: AppTheme.monoStyle(fontSize: 9, color: typeColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            data['description'] as String? ?? data.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.monoStyle(fontSize: 11, color: Colors.white70),
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F141C),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              const JsonEncoder.withIndent('  ').convert(data),
              style: AppTheme.monoStyle(fontSize: 11, color: const Color(0xFF00FF66)),
            ),
          ),
        ],
      ),
    );
  }
}
