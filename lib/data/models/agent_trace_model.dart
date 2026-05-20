/// Represents a single reasoning trace of an autonomous AI agent in the pipeline.
class AgentTraceModel {
  final String stepName;
  final String description;
  final int durationMs;
  final String modelUsed;
  final String status; // "success", "failure", "pending"
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AgentTraceModel({
    required this.stepName,
    required this.description,
    required this.durationMs,
    required this.modelUsed,
    required this.status,
    required this.timestamp,
    this.metadata,
  });

  factory AgentTraceModel.fromJson(Map<String, dynamic> json) => AgentTraceModel(
        stepName: json['stepName'] as String? ?? json['step_name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        durationMs: json['durationMs'] as int? ?? json['duration_ms'] as int? ?? 0,
        modelUsed: json['modelUsed'] as String? ?? json['model'] as String? ?? 'gemini-1.5-flash',
        status: json['status'] as String? ?? 'success',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'stepName': stepName,
        'description': description,
        'durationMs': durationMs,
        'modelUsed': modelUsed,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };
}

/// Represents the overall trace for a booking process.
class BookingTraceModel {
  final String bookingId;
  final List<AgentTraceModel> steps;
  final int totalDurationMs;
  final double confidenceScore;
  final DateTime timestamp;

  const BookingTraceModel({
    required this.bookingId,
    required this.steps,
    required this.totalDurationMs,
    required this.confidenceScore,
    required this.timestamp,
  });

  factory BookingTraceModel.fromJson(Map<String, dynamic> json) => BookingTraceModel(
        bookingId: json['booking_id'] as String? ?? json['bookingId'] as String? ?? '',
        steps: (json['steps'] as List? ?? [])
            .map((s) => AgentTraceModel.fromJson(s as Map<String, dynamic>))
            .toList(),
        totalDurationMs: json['totalDurationMs'] as int? ?? json['total_duration_ms'] as int? ?? 0,
        confidenceScore: (json['confidenceScore'] as num? ?? json['confidence_score'] as num? ?? 1.0).toDouble(),
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'steps': steps.map((s) => s.toJson()).toList(),
        'totalDurationMs': totalDurationMs,
        'confidenceScore': confidenceScore,
        'timestamp': timestamp.toIso8601String(),
      };
}
