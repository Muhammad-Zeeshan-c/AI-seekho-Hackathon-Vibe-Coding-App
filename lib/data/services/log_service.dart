import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Service to log developer events, AI operations, and state changes to a local JSONL file.
class LogService {
  static const String _logFileName = 'kaam_kaar_logs.jsonl';
  static File? _logFile;

  /// Initializes the log file path
  static Future<File> get _file async {
    if (_logFile != null) return _logFile!;
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/$_logFileName');
    return _logFile!;
  }

  /// Appends an event to the local logs
  static Future<void> logEvent(String eventType, Map<String, dynamic> data) async {
    try {
      final file = await _file;
      final event = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': eventType,
        'data': data,
      };
      
      // Write line with newline character (JSON Lines format)
      await file.writeAsString('${jsonEncode(event)}\n', mode: FileMode.append, flush: true);
      print('KaamKaar Log [${eventType}]: ${jsonEncode(data)}');
    } catch (e) {
      print('Error writing log: $e');
    }
  }

  /// Reads and parses all logged events from the local file
  static Future<List<Map<String, dynamic>>> getLogs() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];

      final lines = await file.readAsLines();
      return lines.map((line) {
        try {
          return jsonDecode(line) as Map<String, dynamic>;
        } catch (_) {
          return <String, dynamic>{};
        }
      }).where((element) => element.isNotEmpty).toList();
    } catch (e) {
      print('Error reading logs: $e');
      return [];
    }
  }

  /// Clears the log file
  static Future<void> clearLogs() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing logs: $e');
    }
  }

  /// Exports the log file as a raw JSON string
  static Future<String> exportLogsJson() async {
    try {
      final logs = await getLogs();
      return const JsonEncoder.withIndent('  ').convert(logs);
    } catch (e) {
      return '{"error": "Failed to export: ${e.toString()}"}';
    }
  }
}
