import 'review_model.dart';

/// Represents a service provider/worker on the KaamKaar platform.
class ProviderModel {
  final String id;
  final String name;
  final String category;
  final List<String> subcategories;
  final String phone;
  final String photo;
  final double rating;
  final int reviewCount;
  final String rateType; // "fixed" or "hourly"
  final double rateAmount; // in PKR
  final int yearsExperience;
  final bool verified; // CNIC verified indicator
  final double lat;
  final double lng;
  final double serviceRadiusKm;
  final List<String> availableDays;
  final List<String> availableSlots;
  final List<String> tags;
  final int completedJobs;
  final double cancellationRate;
  final String bio;
  final List<ReviewModel> reviews;
  final List<String> workPhotos;

  // Virtual field calculated dynamically
  final double? distanceKm;
  final String? reasoning; // AI reasoning tag explanation

  const ProviderModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategories,
    required this.phone,
    required this.photo,
    required this.rating,
    required this.reviewCount,
    required this.rateType,
    required this.rateAmount,
    required this.yearsExperience,
    required this.verified,
    required this.lat,
    required this.lng,
    required this.serviceRadiusKm,
    required this.availableDays,
    required this.availableSlots,
    required this.tags,
    required this.completedJobs,
    required this.cancellationRate,
    required this.bio,
    required this.reviews,
    required this.workPhotos,
    this.distanceKm,
    this.reasoning,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) => ProviderModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String? ??
            ((json['service_types'] as List?)?.isNotEmpty == true
                ? (json['service_types'] as List).first as String
                : 'General'),
        subcategories: List<String>.from(json['subcategories'] as List? ?? json['service_types'] as List? ?? []),
        phone: json['phone'] as String? ?? '',
        photo: json['photo'] as String? ?? '',
        rating: (json['rating'] as num? ?? 5.0).toDouble(),
        reviewCount: json['reviewCount'] as int? ?? json['reviews_count'] as int? ?? 0,
        rateType: json['rateType'] as String? ?? json['rate_type'] as String? ?? 'fixed',
        rateAmount: (json['rateAmount'] as num? ?? json['rate_amount'] as num? ?? 0.0).toDouble(),
        yearsExperience: json['yearsExperience'] as int? ?? json['years_experience'] as int? ?? json['experience_years'] as int? ?? 0,
        verified: json['verified'] as bool? ?? json['is_verified'] as bool? ?? false,
        lat: (json['lat'] as num? ?? (json['location'] as Map?)?['lat'] as num? ?? 0.0).toDouble(),
        lng: (json['lng'] as num? ?? (json['location'] as Map?)?['lng'] as num? ?? 0.0).toDouble(),
        serviceRadiusKm: (json['serviceRadiusKm'] as num? ?? json['service_radius_km'] as num? ?? 5.0).toDouble(),
        availableDays: List<String>.from(json['availableDays'] as List? ?? json['available_days'] as List? ?? []),
        availableSlots: List<String>.from(json['availableSlots'] as List? ?? json['available_slots'] as List? ?? []),
        tags: List<String>.from(json['tags'] as List? ?? []),
        completedJobs: json['completedJobs'] as int? ?? json['completed_jobs'] as int? ?? 0,
        cancellationRate: (json['cancellationRate'] as num? ?? json['cancellation_rate'] as num? ?? 0.0).toDouble(),
        bio: json['bio'] as String? ?? '',
        reviews: (json['reviews'] as List? ?? [])
            .map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
            .toList(),
        workPhotos: List<String>.from(json['workPhotos'] as List? ?? json['work_photos'] as List? ?? []),
        distanceKm: (json['distance_km'] as num? ?? (json['distance'] as num?))?.toDouble(),
        reasoning: json['reasoning'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'subcategories': subcategories,
        'phone': phone,
        'photo': photo,
        'rating': rating,
        'reviewCount': reviewCount,
        'rateType': rateType,
        'rateAmount': rateAmount,
        'yearsExperience': yearsExperience,
        'verified': verified,
        'lat': lat,
        'lng': lng,
        'serviceRadiusKm': serviceRadiusKm,
        'availableDays': availableDays,
        'availableSlots': availableSlots,
        'tags': tags,
        'completedJobs': completedJobs,
        'cancellationRate': cancellationRate,
        'bio': bio,
        'reviews': reviews.map((r) => r.toJson()).toList(),
        'workPhotos': workPhotos,
        if (distanceKm != null) 'distance_km': distanceKm,
        if (reasoning != null) 'reasoning': reasoning,
      };

  ProviderModel copyWith({
    String? id,
    String? name,
    String? category,
    List<String>? subcategories,
    String? phone,
    String? photo,
    double? rating,
    int? reviewCount,
    String? rateType,
    double? rateAmount,
    int? yearsExperience,
    bool? verified,
    double? lat,
    double? lng,
    double? serviceRadiusKm,
    List<String>? availableDays,
    List<String>? availableSlots,
    List<String>? tags,
    int? completedJobs,
    double? cancellationRate,
    String? bio,
    List<ReviewModel>? reviews,
    List<String>? workPhotos,
    double? distanceKm,
    String? reasoning,
  }) =>
      ProviderModel(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        subcategories: subcategories ?? this.subcategories,
        phone: phone ?? this.phone,
        photo: photo ?? this.photo,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        rateType: rateType ?? this.rateType,
        rateAmount: rateAmount ?? this.rateAmount,
        yearsExperience: yearsExperience ?? this.yearsExperience,
        verified: verified ?? this.verified,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
        availableDays: availableDays ?? this.availableDays,
        availableSlots: availableSlots ?? this.availableSlots,
        tags: tags ?? this.tags,
        completedJobs: completedJobs ?? this.completedJobs,
        cancellationRate: cancellationRate ?? this.cancellationRate,
        bio: bio ?? this.bio,
        reviews: reviews ?? this.reviews,
        workPhotos: workPhotos ?? this.workPhotos,
        distanceKm: distanceKm ?? this.distanceKm,
        reasoning: reasoning ?? this.reasoning,
      );
}
