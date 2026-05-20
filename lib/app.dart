import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Ignore error if not generated yet
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/localization/language_notifier.dart';

// Screen imports
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/language_screen.dart';
import 'features/onboarding/role_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/worker_dashboard.dart';
import 'features/ai_chat/ai_chat_screen.dart';
import 'features/home/results_screen.dart';
import 'features/home/provider_detail_screen.dart';
import 'features/home/booking_confirm_screen.dart';
import 'features/tracking/tracking_screen.dart';
import 'features/auxiliary/rating_screen.dart';
import 'features/auxiliary/report_screen.dart';
import 'features/auxiliary/history_screen.dart';
import 'features/auxiliary/agent_trace_screen.dart';

/// Root widget — wires theme, localization, and routing
class KaamKaarApp extends ConsumerWidget {
  const KaamKaarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current theme and language from Riverpod
    final themeMode = ref.watch(themeNotifierProvider);
    final locale = ref.watch(languageNotifierProvider);
    final isUrdu = locale.languageCode == 'ur';

    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (ctx, state) => const SplashScreen()),
        GoRoute(path: '/language', builder: (ctx, state) => const LanguageScreen()),
        GoRoute(path: '/role', builder: (ctx, state) => const RoleScreen()),
        GoRoute(
          path: '/login/:role',
          builder: (ctx, state) => LoginScreen(
            initialRole: state.pathParameters['role'] ?? 'user',
          ),
        ),
        GoRoute(
          path: '/register/:role',
          builder: (ctx, state) => RegisterScreen(
            role: state.pathParameters['role'] ?? 'user',
          ),
        ),
        GoRoute(path: '/dashboard/user', builder: (ctx, state) => const HomeScreen()),
        GoRoute(path: '/dashboard/provider', builder: (ctx, state) => const WorkerDashboard()),
        GoRoute(path: '/ai-chat', builder: (ctx, state) => const AiChatScreen()),
        GoRoute(
          path: '/results',
          builder: (ctx, state) => ResultsScreen(
            category: state.uri.queryParameters['category'] ?? 'General',
          ),
        ),
        GoRoute(
          path: '/provider/:id',
          builder: (ctx, state) => ProviderDetailScreen(
            providerId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/booking/confirm',
          builder: (ctx, state) => BookingConfirmScreen(
            providerId: state.uri.queryParameters['providerId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/tracking',
          builder: (ctx, state) => TrackingScreen(
            bookingId: state.uri.queryParameters['bookingId'] ?? '',
            providerId: state.uri.queryParameters['providerId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/feedback/:id',
          builder: (ctx, state) => RatingScreen(bookingId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/report',
          builder: (ctx, state) => ReportScreen(
            providerId: state.uri.queryParameters['providerId'] ?? '',
          ),
        ),
        GoRoute(path: '/history', builder: (ctx, state) => const HistoryScreen()),
        GoRoute(path: '/logs', builder: (ctx, state) => const AgentTraceScreen()),
      ],
      errorBuilder: (ctx, state) => Scaffold(
        body: Center(child: Text('Route not found: ${state.uri}')),
      ),
    );

    return MaterialApp.router(
      title: 'KaamKaar',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme(isUrdu),
      darkTheme: AppTheme.darkTheme(isUrdu),
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: router,
    );
  }
}
