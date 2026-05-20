import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/provider_model.dart';
import '../models/booking_model.dart';
import 'auth_service.dart';

/// Service to handle all business and AI agent network calls on KaamKaar.
class ApiService {
  /// Helper to generate headers with Bearer token
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (AuthService.token != null) 'Authorization': 'Bearer ${AuthService.token}',
      };

  /// Submit a natural language request to the AI multi-agent pipeline
  static Future<Map<String, dynamic>> submitServiceRequest({
    required String userInput,
    required double userLat,
    required double userLng,
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/request'),
      headers: _headers,
      body: jsonEncode({
        'user_input': userInput,
        'user_lat': userLat,
        'user_lng': userLng,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Request failed');
    }
    return data;
  }

  /// Get all verified providers from the backend (optionally filtered by service or area)
  static Future<List<ProviderModel>> getProviders({String? service, String? area}) async {
    final Map<String, String> queryParameters = {
      if (service != null) 'service': service,
      if (area != null) 'area': area,
    };
    
    final baseUri = Uri.parse('$kApiBaseUrl/providers');
    final uri = queryParameters.isNotEmpty 
        ? baseUri.replace(queryParameters: queryParameters)
        : baseUri;

    final response = await http.get(
      uri,
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load providers');
    }
    final list = data['providers'] as List? ?? [];
    return list
        .map((p) => ProviderModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Confirm a booking with a provider
  static Future<BookingModel> confirmBooking({
    required ProviderModel provider,
    required Map<String, dynamic> intent,
    required String selectedSlot,
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/booking'),
      headers: _headers,
      body: jsonEncode({
        'provider': provider.toJson(),
        'intent': intent,
        'selected_slot': selectedSlot,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? 'Booking failed');
    }
    return BookingModel.fromJson(data['booking'] as Map<String, dynamic>);
  }

  /// Get list of bookings for the logged-in client (user)
  static Future<List<BookingModel>> getUserBookings() async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/booking'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load bookings');
    }
    final list = data['bookings'] as List? ?? [];
    return list
        .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  /// Get list of bookings for the logged-in provider
  static Future<List<BookingModel>> getProviderBookings() async {
    final response = await http.get(
      Uri.parse('$kApiBaseUrl/providers/bookings'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load bookings');
    }
    final list = data['bookings'] as List? ?? [];
    return list
        .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  /// Respond to a booking request (accept or decline)
  static Future<void> respondToBooking({
    required String bookingId,
    required String action, // 'accept' or 'decline'
  }) async {
    final response = await http.put(
      Uri.parse('$kApiBaseUrl/providers/bookings/$bookingId/respond'),
      headers: _headers,
      body: jsonEncode({'action': action}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error'] ?? 'Failed to respond to booking');
    }
  }

  /// Submit feedback and rating for a booking
  static Future<void> submitFeedback({
    required String bookingId,
    required String providerId,
    required int rating,
    required String comment,
    bool wouldBookAgain = false,
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/feedback'),
      headers: _headers,
      body: jsonEncode({
        'booking_id': bookingId,
        'provider_id': providerId,
        'rating': rating,
        'comment': comment,
        'would_book_again': wouldBookAgain,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error'] ?? 'Failed to submit feedback');
    }
  }
}
