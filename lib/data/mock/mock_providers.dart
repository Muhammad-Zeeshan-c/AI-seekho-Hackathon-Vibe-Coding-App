import 'dart:math';
import '../models/provider_model.dart';
import '../models/review_model.dart';

/// Database helper containing a procedurally generated list of exactly 100 service providers.
class MockProviderDatabase {
  static final List<ProviderModel> _providers = [];

  static List<ProviderModel> get providers {
    if (_providers.isEmpty) {
      _generateMockProviders();
    }
    return _providers;
  }

  static void _generateMockProviders() {
    final Random random = Random(42); // Seeded for reproducibility

    final List<String> firstNames = [
      'Ali', 'Hassan', 'Muhammad', 'Ahmad', 'Zain', 'Usman', 'Bilal', 'Hamza', 'Umar',
      'Farhan', 'Yasir', 'Tariq', 'Imran', 'Salman', 'Junaid', 'Faisal', 'Kashif', 'Asif',
      'Zeeshan', 'Nabeel', 'Babar', 'Haris', 'Rizwan', 'Waqas', 'Fahad', 'Sajid', 'Naeem',
      'Kamran', 'Zahid', 'Arsalan', 'Khurram', 'Aamir', 'Sohail', 'Javed', 'Saqib', 'Adeel',
      'Adnan', 'Taimoor', 'Shehryar', 'Waseem', 'Amjad', 'Tahir', 'Nadeem', 'Shahid', 'Irfan'
    ];

    final List<String> lastNames = [
      'Khan', 'Ahmed', 'Hassan', 'Bhatti', 'Butt', 'Malik', 'Chaudhry', 'Mughal', 'Raza',
      'Awan', 'Sheikh', 'Siddiqui', 'Qureshi', 'Shah', 'Abbasi', 'Jamil', 'Zafar', 'Akram',
      'Zubair', 'Lodhi', 'Dar', 'Gill', 'Guijar', 'Hashmi', 'Latif', 'Mehmood', 'Rasheed'
    ];

    final List<String> femaleFirstNames = [
      'Sara', 'Ayesha', 'Fatima', 'Amna', 'Sana', 'Hina', 'Zainab', 'Mariam', 'Sadia',
      'Nida', 'Kiran', 'Noreen', 'Uzma', 'Bushra', 'Sobia', 'Farah', 'Mehak', 'Alina'
    ];

    // Pakistan base locations
    // G-13 base: 33.6844, 73.0479 (30 providers)
    // F-7 base: 33.7297, 73.0545 (20 providers)
    // DHA Lahore base: 31.4697, 74.4084 (25 providers)
    // Gulshan Karachi base: 24.9180, 67.0971 (25 providers)
    final List<Map<String, dynamic>> regions = [
      {'name': 'Islamabad G-13', 'lat': 33.6844, 'lng': 73.0479, 'count': 30},
      {'name': 'Islamabad F-7', 'lat': 33.7297, 'lng': 73.0545, 'count': 20},
      {'name': 'DHA Lahore', 'lat': 31.4697, 'lng': 74.4084, 'count': 25},
      {'name': 'Gulshan Karachi', 'lat': 24.9180, 'lng': 67.0971, 'count': 25},
    ];

    final List<Map<String, dynamic>> categoriesInfo = [
      {
        'category': 'Electrician',
        'sub': ['Wiring', 'Inverter Installation', 'Switchboard Repair', 'CCTV Setup'],
        'rate': 1200.0,
        'type': 'fixed',
        'tags': ['Inverter expert', 'Wiring professional', 'Quick repair'],
        'count': 15
      },
      {
        'category': 'Plumber',
        'sub': ['Pipe Fitting', 'Water Motor Repair', 'Drainage Cleaning', 'Tap Leaks'],
        'rate': 1000.0,
        'type': 'fixed',
        'tags': ['Leak specialist', 'Fast responder', 'Neat work'],
        'count': 15
      },
      {
        'category': 'AC Technician',
        'sub': ['Split AC Service', 'Window AC Service', 'Gas Refill', 'Compressor Repair'],
        'rate': 1800.0,
        'type': 'fixed',
        'tags': ['AC Service expert', 'Gas leak detection', 'Inverter AC specialist'],
        'count': 12
      },
      {
        'category': 'Carpenter',
        'sub': ['Furniture Polish', 'Door Repair', 'Cabinet Assembly', 'Lock Fitting'],
        'rate': 400.0,
        'type': 'hourly',
        'tags': ['Fine wood finishing', 'Door fitting expert', 'Reliable pricing'],
        'count': 10
      },
      {
        'category': 'Painter',
        'sub': ['Interior Wall Painting', 'Exterior Wall Painting', 'Waterproofing', 'Wall Putty'],
        'rate': 350.0,
        'type': 'hourly',
        'tags': ['Neat painting', 'Wall waterproofing expert', 'Fast painter'],
        'count': 8
      },
      {
        'category': 'Tutor',
        'sub': ['Mathematics Tuition', 'Science Tuition', 'English Language', 'O-Levels Prep'],
        'rate': 800.0,
        'type': 'hourly',
        'tags': ['Maths expert', 'Conceptual learning', 'Punctual tutor'],
        'count': 10
      },
      {
        'category': 'Beautician',
        'sub': ['Bridal Makeup', 'Threading & Waxing', 'Facial Treatment', 'Hair Styling'],
        'rate': 2500.0,
        'type': 'fixed',
        'tags': ['Bridal makeup expert', 'Salon at home', 'Hygiene focused'],
        'count': 8
      },
      {
        'category': 'Driver',
        'sub': ['Daily Commute Driver', 'Airport Pickup', 'Inter-city Travel', 'Valet service'],
        'rate': 500.0,
        'type': 'hourly',
        'tags': ['Safe driver', 'Punctual', 'Clean record'],
        'count': 8
      },
      {
        'category': 'Plumber-Gas',
        'sub': ['Gas Pipe Installation', 'Geyser Service', 'Stove Cleaning', 'Gas Leak Repair'],
        'rate': 1200.0,
        'type': 'fixed',
        'tags': ['Geyser specialist', 'Gas leak expert', 'Safe repairs'],
        'count': 7
      },
      {
        'category': 'Gardener',
        'sub': ['Lawn Mowing', 'Plant Care & Pruning', 'Soil Fertilization', 'Garden Design'],
        'rate': 300.0,
        'type': 'hourly',
        'tags': ['Lawn care specialist', 'Plant grafting expert', 'Creative landscaping'],
        'count': 7
      },
    ];

    final List<Map<String, dynamic>> commentsUrduAndEnglish = [
      {'text': 'Bohot accha kaam kiya. Waqt par aaye aur kaam bilkul sahi kiya.', 'rating': 5},
      {'text': 'Highly professional AC service. Charges were exactly as estimated.', 'rating': 5},
      {'text': 'Kaam theek tha, lekin thora late aaye thay. Overall satisfied.', 'rating': 4},
      {'text': 'Zabardast kaam! Ali bhai bohot tameezdar hain aur kaam bohot safai se kiya.', 'rating': 5},
      {'text': 'Recommended tutor. My kids have improved their grades significantly.', 'rating': 5},
      {'text': 'Electrician was knowledgeable, but charged a bit high for minor wiring.', 'rating': 3},
      {'text': 'Safe driving and very punctual. Highly recommended for family trips.', 'rating': 5},
      {'text': 'Geyser service was quick. Ready for winters now. Thank you KaamKaar!', 'rating': 5},
      {'text': 'Beautician did a great job. Clean tools and professional behavior.', 'rating': 4},
      {'text': 'Plumber fixed the pipe leak instantly. Honest pricing.', 'rating': 5},
      {'text': 'Kaam to sahi kar diya par safai nahi ki janay se pehlay.', 'rating': 3},
      {'text': 'Very humble person. Explained the problem before fixing it.', 'rating': 5},
    ];

    int providerIndex = 1;

    // Distribute providers across categories first
    for (var catInfo in categoriesInfo) {
      final String category = catInfo['category'] as String;
      final int countNeeded = catInfo['count'] as int;

      for (int i = 0; i < countNeeded; i++) {
        // Pick a name
        final bool isBeautician = category == 'Beautician';
        String pName;
        if (isBeautician) {
          pName = '${femaleFirstNames[random.nextInt(femaleFirstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
        } else {
          pName = '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
        }

        // Pick a region based on simple round robin/random distribution
        final int regionIdx = (providerIndex - 1) % regions.length;
        final region = regions[regionIdx];

        // Slightly jitter the coordinates to spread them around base location
        final double latJitter = (random.nextDouble() - 0.5) * 0.04;
        final double lngJitter = (random.nextDouble() - 0.5) * 0.04;
        final double plat = (region['lat'] as double) + latJitter;
        final double plng = (region['lng'] as double) + lngJitter;

        // Generate experience, rating
        final int experience = random.nextInt(15) + 2; // 2 to 16 years
        final double rating = 3.5 + (random.nextDouble() * 1.5); // 3.5 to 5.0
        final int completedJobs = (experience * 35) + random.nextInt(100);
        final int reviewsCount = (completedJobs * 0.4).round();

        // Calculate rate variations
        final double rateBase = catInfo['rate'] as double;
        final double rateAmount = (rateBase + (random.nextInt(6) * 100.0 - 300.0)).clamp(300.0, 10000.0);

        // Generate reviews list
        final List<ReviewModel> reviews = [];
        final int reviewsToGen = min(reviewsCount, 6);
        for (int r = 0; r < reviewsToGen; r++) {
          final reviewComment = commentsUrduAndEnglish[random.nextInt(commentsUrduAndEnglish.length)];
          final clientName = random.nextBool()
              ? femaleFirstNames[random.nextInt(femaleFirstNames.length)]
              : firstNames[random.nextInt(firstNames.length)];
          reviews.add(
            ReviewModel(
              reviewerName: '$clientName ${random.nextBool() ? 'K.' : 'A.'}',
              rating: reviewComment['rating'] as int,
              date: '2026-05-${(10 + random.nextInt(10)).toString().padLeft(2, '0')}',
              comment: reviewComment['text'] as String,
              tags: List<String>.from((catInfo['tags'] as List).take(1 + random.nextInt(2))),
            ),
          );
        }

        // Days and slots
        final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        if (random.nextBool()) days.add('Sun');

        final List<String> slots = ['09:00', '10:00', '11:00', '12:00', '14:00', '15:00', '16:00', '17:00'];
        final List<String> pSlots = List<String>.from(slots)..shuffle(random);
        final List<String> pAvailableSlots = pSlots.take(3 + random.nextInt(4)).toList()..sort();

        // Work photos
        final List<String> workPhotos = [
          'https://images.unsplash.com/photo-1581092921461-eab62e97a780?w=500',
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500',
        ];

        final String pId = 'PRV-${providerIndex.toString().padLeft(3, '0')}';

        _providers.add(
          ProviderModel(
            id: pId,
            name: pName,
            category: category,
            subcategories: List<String>.from((catInfo['sub'] as List).take(2 + random.nextInt(2))),
            phone: '+92-300-${(1000000 + random.nextInt(9000000))}',
            photo: 'https://api.dicebear.com/7.x/initials/svg?seed=$pName',
            rating: double.parse(rating.toStringAsFixed(1)),
            reviewCount: reviewsCount,
            rateType: catInfo['type'] as String,
            rateAmount: rateAmount,
            yearsExperience: experience,
            verified: random.nextDouble() > 0.15, // 85% verified CNIC
            lat: plat,
            lng: plng,
            serviceRadiusKm: 5.0 + random.nextInt(10), // 5km to 15km
            availableDays: days,
            availableSlots: pAvailableSlots,
            tags: List<String>.from(catInfo['tags'] as List)..shuffle(random),
            completedJobs: completedJobs,
            cancellationRate: double.parse((random.nextDouble() * 0.08).toStringAsFixed(2)),
            bio: '$experience saal ka tajurba hai. $category ki behtareen services ke liye rabta karein.',
            reviews: reviews,
            workPhotos: workPhotos,
          ),
        );

        providerIndex++;
      }
    }

    // Fill remaining to ensure exactly 100
    while (providerIndex <= 100) {
      final region = regions[random.nextInt(regions.length)];
      final catInfo = categoriesInfo[random.nextInt(categoriesInfo.length)];
      final String category = catInfo['category'] as String;

      final pName = '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
      final double plat = (region['lat'] as double) + (random.nextDouble() - 0.5) * 0.04;
      final double plng = (region['lng'] as double) + (random.nextDouble() - 0.5) * 0.04;

      final String pId = 'PRV-${providerIndex.toString().padLeft(3, '0')}';

      _providers.add(
        ProviderModel(
          id: pId,
          name: pName,
          category: category,
          subcategories: List<String>.from(catInfo['sub'] as List),
          phone: '+92-300-${(1000000 + random.nextInt(9000000))}',
          photo: 'https://api.dicebear.com/7.x/initials/svg?seed=$pName',
          rating: 4.5,
          reviewCount: 15,
          rateType: catInfo['type'] as String,
          rateAmount: catInfo['rate'] as double,
          yearsExperience: 5,
          verified: true,
          lat: plat,
          lng: plng,
          serviceRadiusKm: 10.0,
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
          availableSlots: ['10:00', '11:00', '14:00', '15:00'],
          tags: List<String>.from(catInfo['tags'] as List),
          completedJobs: 45,
          cancellationRate: 0.01,
          bio: 'Behtareen kaam aur munasib rates.',
          reviews: [],
          workPhotos: [],
        ),
      );

      providerIndex++;
    }
  }
}
