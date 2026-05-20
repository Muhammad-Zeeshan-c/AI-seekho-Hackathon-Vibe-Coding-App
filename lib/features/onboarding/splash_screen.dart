import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

/// Premium animated splash screen with neural-pulse ring animation
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();

    // Outer ring pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    // Rotating ring animation
    _ringController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Navigate after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final hasLanguage = prefs.getString('app_language') != null;
        if (hasLanguage) {
          context.go('/role');
        } else {
          context.go('/language');
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        // Full-screen gradient background
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF000000), Color(0xFF0D0D1A), Color(0xFF0A0A14)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF1A7FE8), Color(0xFF5B4FE8), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background decorative circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),

            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with pulsing rings
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulsing ring
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) => Container(
                          width: 130 + (_pulseController.value * 10),
                          height: 130 + (_pulseController.value * 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15 - (_pulseController.value * 0.1)),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Rotating dashed ring
                      AnimatedBuilder(
                        animation: _ringController,
                        builder: (context, child) => Transform.rotate(
                          angle: _ringController.value * 2 * 3.14159,
                          child: child,
                        ),
                        child: Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      // Logo circle
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                        ),
                        child: const Center(
                          child: Text('⚡', style: TextStyle(fontSize: 38)),
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 28),

                // App name
                const Text(
                  'KaamKaar',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 10),

                // Tagline
                Text(
                  'Kaam Karo, Aage Baro',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 6),

                // Subtitle
                Text(
                  'Pakistan\'s AI Service Platform',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ).animate(delay: 700.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 60),

                // Loading indicator
                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 2,
                    ),
                  ),
                ).animate(delay: 800.ms).fadeIn(duration: 300.ms),
              ],
            ),

            // Bottom badge
            Positioned(
              bottom: 40,
              child: Column(
                children: [
                  Text(
                    'Powered by Google Antigravity',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI Seekho Pakistan Hackathon 2026',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 10,
                    ),
                  ),
                ],
              ).animate(delay: 900.ms).fadeIn(duration: 500.ms),
            ),
          ],
        ),
      ),
    );
  }
}
