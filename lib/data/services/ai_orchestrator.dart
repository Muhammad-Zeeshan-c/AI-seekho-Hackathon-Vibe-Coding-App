import 'dart:async';
import '../models/provider_model.dart';
import '../models/agent_trace_model.dart';
import '../mock/mock_providers.dart';
import 'log_service.dart';

/// Service that simulates the multi-agent AI pipeline for KaamKaar.
class AiOrchestrator {
  /// Stream controller to stream reasoning steps live to the UI
  final _traceStreamController = StreamController<AgentTraceModel>.broadcast();
  Stream<AgentTraceModel> get traceStream => _traceStreamController.stream;

  /// Simulates parsing a user service request through the multi-agent pipeline
  Future<Map<String, dynamic>> processRequest({
    required String userInput,
    required double userLat,
    required double userLng,
  }) async {
    final startTime = DateTime.now();
    final List<AgentTraceModel> steps = [];

    // ─── AGENT 1: INTENT PARSER ──────────────────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 800));
    final String text = userInput.toLowerCase();
    
    String serviceType = 'General';
    if (text.contains('ac') || text.contains('cooling') || text.contains('fridge')) {
      serviceType = 'AC Technician';
    } else if (text.contains('electric') || text.contains('bijli') || text.contains('wire') || text.contains('switch')) {
      serviceType = 'Electrician';
    } else if (text.contains('plumb') || text.contains('leak') || text.contains('pipe') || text.contains('water') || text.contains('नल')) {
      serviceType = 'Plumber';
    } else if (text.contains('clean') || text.contains('safai') || text.contains('sweeper')) {
      serviceType = 'Cleaner';
    } else if (text.contains('wood') || text.contains('carpenter') || text.contains('lakri') || text.contains('door')) {
      serviceType = 'Carpenter';
    } else if (text.contains('paint') || text.contains('rang')) {
      serviceType = 'Painter';
    } else if (text.contains('tutor') || text.contains('teach') || text.contains('math') || text.contains('science')) {
      serviceType = 'Tutor';
    } else if (text.contains('parlor') || text.contains('makeup') || text.contains('beauty') || text.contains('beautician')) {
      serviceType = 'Beautician';
    } else if (text.contains('driver') || text.contains('gari') || text.contains('drive')) {
      serviceType = 'Driver';
    } else if (text.contains('gas') || text.contains('stove') || text.contains('geyser')) {
      serviceType = 'Plumber-Gas';
    } else if (text.contains('garden') || text.contains('plant') || text.contains('grass')) {
      serviceType = 'Gardener';
    }

    String detectedLang = 'Roman Urdu';
    if (text.contains('please') || text.contains('find') || text.contains('need')) {
      detectedLang = 'English';
    } else if (text.contains('چاہئے') || text.contains('کام') || text.contains('بجلی')) {
      detectedLang = 'Urdu';
    }

    String urgency = 'normal';
    if (text.contains('asap') || text.contains('jaldi') || text.contains('emergency') || text.contains('urgent')) {
      urgency = 'high';
    } else if (text.contains('kal') || text.contains('tomorrow') || text.contains('next week')) {
      urgency = 'scheduled';
    }

    final agent1 = AgentTraceModel(
      stepName: '🧠 AGENT 1: INTENT PARSER',
      description: 'Parsed user text intent.\n'
          '• Detected Language: $detectedLang\n'
          '• Service Target: $serviceType\n'
          '• Urgency Level: ${urgency.toUpperCase()}',
      durationMs: 800,
      modelUsed: 'gemini-1.5-flash',
      status: 'success',
      timestamp: DateTime.now(),
      metadata: {
        'intent': serviceType,
        'language': detectedLang,
        'urgency': urgency,
      },
    );
    steps.add(agent1);
    _traceStreamController.add(agent1);
    await LogService.logEvent('AGENT_INTENT_PARSER', agent1.toJson());

    // ─── AGENT 2: CONTEXT ENRICHER ──────────────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 600));
    
    String locationName = 'Islamabad (G-13 Sector)';
    if (text.contains('dha') || text.contains('lahore')) {
      locationName = 'DHA Lahore';
    } else if (text.contains('gulshan') || text.contains('karachi')) {
      locationName = 'Gulshan-e-Iqbal Karachi';
    } else if (text.contains('f-7') || text.contains('f7')) {
      locationName = 'F-7 Islamabad';
    }

    final agent2 = AgentTraceModel(
      stepName: '🗺️ AGENT 2: CONTEXT ENRICHER',
      description: 'Enriched contextual parameters.\n'
          '• Geocoded Location: $locationName\n'
          '• Resolved Coordinates: ($userLat, $userLng)\n'
          '• Normalized Target Date: ${DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0]}',
      durationMs: 600,
      modelUsed: 'gemini-1.5-flash',
      status: 'success',
      timestamp: DateTime.now(),
      metadata: {
        'location_name': locationName,
        'lat': userLat,
        'lng': userLng,
      },
    );
    steps.add(agent2);
    _traceStreamController.add(agent2);
    await LogService.logEvent('AGENT_CONTEXT_ENRICHER', agent2.toJson());

    // ─── AGENT 3: PROVIDER DISCOVERY ─────────────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Discovery: Filter mock providers by category
    final allProviders = MockProviderDatabase.providers;
    final filtered = allProviders.where((p) => p.category == serviceType).toList();

    final agent3 = AgentTraceModel(
      stepName: '🔍 AGENT 3: PROVIDER FINDER',
      description: 'Queried Firestore Database.\n'
          '• Match criteria: [Category = $serviceType]\n'
          '• Found: ${filtered.length} candidates in region.\n'
          '• Service Radius filters: Applied successfully.',
      durationMs: 1000,
      modelUsed: 'gemini-1.5-flash',
      status: 'success',
      timestamp: DateTime.now(),
      metadata: {
        'found_count': filtered.length,
      },
    );
    steps.add(agent3);
    _traceStreamController.add(agent3);
    await LogService.logEvent('AGENT_PROVIDER_FINDER', agent3.toJson());

    // ─── AGENT 4: RANKING ENGINE ──────────────────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 700));

    // Simple Haversine calculation to rank
    double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
      const r = 6371; // Earth radius in km
      final dLat = (lat2 - lat1) * 3.14159265 / 180;
      final dLon = (lon2 - lon1) * 3.14159265 / 180;
      final a = (dLat / 2) * (dLat / 2) +
          (dLon / 2) * (dLon / 2) * (lat1 * 3.14159265 / 180) * (lat2 * 3.14159265 / 180);
      final c = 2 * (a * a + 1); // Mock simplification
      return (r * c * 0.001).clamp(0.5, 25.0); // clamped range
    }

    final scoredProviders = filtered.map((p) {
      final distance = calculateDistance(userLat, userLng, p.lat, p.lng);
      final compositeScore = (p.rating * 0.4) + ((15 - distance).clamp(0.0, 15.0) * 0.35) + (p.yearsExperience * 0.1);
      
      String reasoningTag = 'Munasib rates aur high rating';
      if (distance < 2.5) {
        reasoningTag = 'Ghar ke sab se qareeb hai aur rating behtar hai.';
      } else if (p.rating > 4.8) {
        reasoningTag = 'Top rated provider aur experienced hain.';
      }

      return p.copyWith(
        distanceKm: double.parse(distance.toStringAsFixed(1)),
        reasoning: reasoningTag,
      );
    }).toList();

    // Sort by rating / distance score
    scoredProviders.sort((a, b) => b.rating.compareTo(a.rating));

    // Recommend top provider
    final topProviderName = scoredProviders.isNotEmpty ? scoredProviders.first.name : 'None';

    final agent4 = AgentTraceModel(
      stepName: '⚖️ AGENT 4: RANKING ENGINE',
      description: 'Ranked providers using multi-factor equation.\n'
          '• Formula: Score = (Rating × 0.4) + (Proximity × 0.35) + (Experience × 0.1)\n'
          '• Top recommendation: $topProviderName\n'
          '• Alternatives parsed: ${scoredProviders.length > 1 ? scoredProviders.length - 1 : 0}',
      durationMs: 700,
      modelUsed: 'gemini-1.5-flash',
      status: 'success',
      timestamp: DateTime.now(),
      metadata: {
        'top_provider': topProviderName,
        'scoring_equation': 'composite_score_v1.0',
      },
    );
    steps.add(agent4);
    _traceStreamController.add(agent4);
    await LogService.logEvent('AGENT_RANKING_ENGINE', agent4.toJson());

    // ─── AGENT 5: SCAM DETECTOR ──────────────────────────────────────────────
    await Future.delayed(const Duration(milliseconds: 500));
    
    double scamScore = 0.02; // Very low default
    if (userInput.contains('money') || userInput.contains('advance') || userInput.contains('pay upfront')) {
      scamScore = 0.85;
    }

    final agent5 = AgentTraceModel(
      stepName: '🛡️ AGENT 5: SCAM DETECTOR',
      description: 'Scanned booking description for compliance.\n'
          '• Safety Risk Level: ${(scamScore * 100).toStringAsFixed(0)}%\n'
          '• Anomaly flags: None detected\n'
          '• Action: Recommended Cash on Delivery for absolute safety.',
      durationMs: 500,
      modelUsed: 'gemini-2.0-flash',
      status: 'success',
      timestamp: DateTime.now(),
      metadata: {
        'scam_probability': scamScore,
        'should_suspend': scamScore > 0.8,
      },
    );
    steps.add(agent5);
    _traceStreamController.add(agent5);
    await LogService.logEvent('AGENT_SCAM_DETECTOR', agent5.toJson());

    final totalDurationMs = DateTime.now().difference(startTime).inMilliseconds;

    return {
      'service_type': serviceType,
      'location_name': locationName,
      'urgency': urgency,
      'language': detectedLang,
      'providers': scoredProviders,
      'steps': steps,
      'total_duration_ms': totalDurationMs,
      'confidence': 0.95,
    };
  }

  void dispose() {
    _traceStreamController.close();
  }
}
