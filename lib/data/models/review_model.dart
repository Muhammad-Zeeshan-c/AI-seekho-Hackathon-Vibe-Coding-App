/// ReviewModel represents user feedback on a provider's service.
class ReviewModel {
  final String reviewerName;
  final int rating;
  final String date;
  final String comment;
  final List<String> tags;

  const ReviewModel({
    required this.reviewerName,
    required this.rating,
    required this.date,
    required this.comment,
    required this.tags,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        reviewerName: json['reviewerName'] as String? ?? json['reviewer_name'] as String? ?? 'Anonymous User',
        rating: json['rating'] as int? ?? 5,
        date: json['date'] as String? ?? '',
        comment: json['comment'] as String? ?? '',
        tags: List<String>.from(json['tags'] as List? ?? []),
      );

  Map<String, dynamic> toJson() => {
        'reviewerName': reviewerName,
        'rating': rating,
        'date': date,
        'comment': comment,
        'tags': tags,
      };
}
