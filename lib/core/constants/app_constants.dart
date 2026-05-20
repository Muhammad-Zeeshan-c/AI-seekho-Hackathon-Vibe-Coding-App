// KaamKaar core application constants

/// API Base URL (For Android Emulator pointing to local machine: http://10.0.2.2:3000/api)
const String kApiBaseUrl = 'http://10.0.2.2:3000/api';

/// DiceBear avatar base URL for generating random profile icons
const String kAvatarBaseUrl = 'https://api.dicebear.com/7.x/initials/svg?seed=';

/// SharedPreferences keys
const String kAuthTokenKey = 'kaamkaar_auth_token';
const String kAuthUserKey = 'kaamkaar_auth_user';
const String kLanguageKey = 'kaamkaar_lang';

/// Default coordinates (Islamabad)
const double kDefaultLat = 33.6844;
const double kDefaultLng = 73.0479;

/// Available service categories
const List<String> kServiceCategories = [
  'All',
  'Electrician',
  'Plumber',
  'AC Technician',
  'Cleaner',
  'Carpenter',
  'Painter',
  'Tutor',
  'Beautician',
  'Driver',
];

/// Category icons map (Emojis used as icons for maximum reliability across setups)
const Map<String, String> kCategoryIcons = {
  'All': '💼',
  'Electrician': '⚡',
  'Plumber': '🔧',
  'AC Technician': '❄️',
  'Cleaner': '🧹',
  'Carpenter': '🪚',
  'Painter': '🖌️',
  'Tutor': '📚',
  'Beautician': '💄',
  'Driver': '🚗',
};

/// User roles
const String kRoleUser = 'user';
const String kRoleProvider = 'provider';
const String kRoleAdmin = 'admin';
