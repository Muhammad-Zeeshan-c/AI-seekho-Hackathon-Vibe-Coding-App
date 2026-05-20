/// BookingModel represents a scheduled or active home service booking.
class BookingModel {
  final String id;
  final String clientId;
  final String providerId;
  final String providerName;
  final String service;
  final String status; // "confirmed", "en_route", "arrived", "started", "completed", "cancelled"
  final String scheduledDatetime;
  final String userLocationText;
  final double userLat;
  final double userLng;
  final String estimatedCost;
  final String confirmationMessage;
  final double workerLat; // for live map tracking
  final double workerLng; // for live map tracking
  final DateTime createdAt;
  final int durationMinutes;

  const BookingModel({
    required this.id,
    required this.clientId,
    required this.providerId,
    required this.providerName,
    required this.service,
    required this.status,
    required this.scheduledDatetime,
    required this.userLocationText,
    required this.userLat,
    required this.userLng,
    required this.estimatedCost,
    required this.confirmationMessage,
    required this.workerLat,
    required this.workerLng,
    required this.createdAt,
    required this.durationMinutes,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['booking_id'] as String? ?? json['id'] as String? ?? '',
        clientId: json['clientId'] as String? ?? json['client_id'] as String? ?? '',
        providerId: json['providerId'] as String? ?? json['provider_id'] as String? ?? '',
        providerName: json['providerName'] as String? ?? json['provider_name'] as String? ?? '',
        service: json['service'] as String? ?? '',
        status: json['status'] as String? ?? 'confirmed',
        scheduledDatetime: json['scheduledDatetime'] as String? ?? json['scheduled_datetime'] as String? ?? '',
        userLocationText: json['userLocationText'] as String? ?? json['user_location'] as String? ?? 'Islamabad',
        userLat: (json['userLat'] as num? ?? json['user_lat'] as num? ?? 33.6844).toDouble(),
        userLng: (json['userLng'] as num? ?? json['user_lng'] as num? ?? 73.0479).toDouble(),
        estimatedCost: json['estimatedCost'] as String? ?? json['estimated_cost'] as String? ?? 'PKR 1,500',
        confirmationMessage: json['confirmationMessage'] as String? ?? json['confirmation_message'] as String? ?? '',
        workerLat: (json['workerLat'] as num? ?? json['worker_lat'] as num? ?? 33.6844).toDouble(),
        workerLng: (json['workerLng'] as num? ?? json['worker_lng'] as num? ?? 73.0479).toDouble(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
        durationMinutes: json['durationMinutes'] as int? ?? json['duration_minutes'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'booking_id': id,
        'clientId': clientId,
        'providerId': providerId,
        'providerName': providerName,
        'service': service,
        'status': status,
        'scheduledDatetime': scheduledDatetime,
        'userLocationText': userLocationText,
        'userLat': userLat,
        'userLng': userLng,
        'estimatedCost': estimatedCost,
        'confirmationMessage': confirmationMessage,
        'workerLat': workerLat,
        'workerLng': workerLng,
        'created_at': createdAt.toIso8601String(),
        'durationMinutes': durationMinutes,
      };

  BookingModel copyWith({
    String? id,
    String? clientId,
    String? providerId,
    String? providerName,
    String? service,
    String? status,
    String? scheduledDatetime,
    String? userLocationText,
    double? userLat,
    double? userLng,
    String? estimatedCost,
    String? confirmationMessage,
    double? workerLat,
    double? workerLng,
    DateTime? createdAt,
    int? durationMinutes,
  }) =>
      BookingModel(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        providerId: providerId ?? this.providerId,
        providerName: providerName ?? this.providerName,
        service: service ?? this.service,
        status: status ?? this.status,
        scheduledDatetime: scheduledDatetime ?? this.scheduledDatetime,
        userLocationText: userLocationText ?? this.userLocationText,
        userLat: userLat ?? this.userLat,
        userLng: userLng ?? this.userLng,
        estimatedCost: estimatedCost ?? this.estimatedCost,
        confirmationMessage: confirmationMessage ?? this.confirmationMessage,
        workerLat: workerLat ?? this.workerLat,
        workerLng: workerLng ?? this.workerLng,
        createdAt: createdAt ?? this.createdAt,
        durationMinutes: durationMinutes ?? this.durationMinutes,
      );
}
