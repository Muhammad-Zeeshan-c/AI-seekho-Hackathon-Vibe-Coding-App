import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_providers.dart';
import '../../data/models/provider_model.dart';
import '../../data/services/tracking_simulator.dart';

/// Live worker tracking screen — Uber-style with animated marker + ETA countdown
class TrackingScreen extends StatefulWidget {
  final String bookingId;
  final String providerId;
  const TrackingScreen({super.key, required this.bookingId, required this.providerId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late ProviderModel _provider;
  late MapController _mapController;
  late TrackingSimulator _simulator;

  LatLng _workerPos = const LatLng(33.6938, 73.0652);
  static const LatLng _clientPos = LatLng(33.6844, 73.0479);
  double _etaMinutes = 18;
  bool _workerArrived = false;
  int _statusIndex = 2; // 0=confirmed,1=notified,2=enRoute,3=arrived,4=started,5=completed

  static const _statuses = [
    'Booking Confirmed',
    'Worker Notified',
    'Worker En Route',
    'Worker Arrived',
    'Service Started',
    'Service Completed',
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _provider = MockProviderDatabase.providers.firstWhere(
      (p) => p.id == widget.providerId,
      orElse: () => MockProviderDatabase.providers.first,
    );

    _simulator = TrackingSimulator(
      workerStart: _workerPos,
      clientLocation: _clientPos,
      numPoints: 20,
    );

    // Start movement simulation
    _simulator.startSimulation((pos, eta) {
      if (!mounted) return;
      setState(() {
        _workerPos = pos;
        _etaMinutes = eta;
      });
      // Animate camera to follow worker
      _mapController.move(pos, 15.0);

      if (eta <= 0.5 && !_workerArrived) {
        setState(() {
          _workerArrived = true;
          _statusIndex = 3;
        });
        _showArrivalBanner();
      }
    });
  }

  @override
  void dispose() {
    _simulator.stopSimulation();
    super.dispose();
  }

  void _showArrivalBanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              '${_provider.name.split(' ').first} has arrived!',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
        backgroundColor: AppTheme.accent,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(33.6891, 73.0565),
              initialZoom: 14.5,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              // Tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'pk.kaamkaar.app',
              ),

              // Route polyline (mock)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _simulator.routePoints,
                    strokeWidth: 4,
                    color: AppTheme.primary.withOpacity(0.8),
                  ),
                ],
              ),

              // Client location (blue pulsing dot)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _clientPos,
                    width: 60,
                    height: 60,
                    child: _PulsingDot(color: AppTheme.primary),
                  ),
                  // Worker marker
                  Marker(
                    point: _workerPos,
                    width: 50,
                    height: 50,
                    child: _WorkerMarker(
                      name: _provider.name[0],
                      arrived: _workerArrived,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surface2Dark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppTheme.textPrimary(context)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surface2Dark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: _workerArrived ? AppTheme.accent : AppTheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _workerArrived ? '${_provider.name.split(" ").first} has arrived! 🎉' : '${_provider.name.split(" ").first} is on the way',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary(context)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ETA badge
          if (!_workerArrived)
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surface2Dark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text(
                      '${_etaMinutes.ceil()}',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: AppTheme.accent),
                    ),
                    Text('min', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: AppTheme.accent.withOpacity(0.2)),
            ),

          // Bottom draggable sheet
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.2,
            maxChildSize: 0.75,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppTheme.divider(context), borderRadius: BorderRadius.circular(4)),
                    ),

                    // Worker info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: isDark ? AppTheme.primaryDark.withOpacity(0.2) : AppTheme.primary.withOpacity(0.1),
                            child: Text(_provider.name[0], style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: isDark ? AppTheme.primaryDark : AppTheme.primary)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_provider.name, style: Theme.of(context).textTheme.titleMedium),
                                Text('${_provider.category} · ⭐ ${_provider.rating}', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          // Action buttons
                          Row(
                            children: [
                              _ActionBtn(icon: Icons.call_rounded, color: AppTheme.accent, isDark: isDark, onTap: () {}),
                              const SizedBox(width: 8),
                              _ActionBtn(icon: Icons.chat_rounded, color: AppTheme.primary, isDark: isDark, onTap: () => context.push('/ai-chat')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Divider(color: AppTheme.divider(context), height: 1),
                    const SizedBox(height: 16),

                    // Status timeline
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status Timeline', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 14),
                          ...List.generate(_statuses.length, (i) {
                            final isDone = i <= _statusIndex;
                            final isCurrent = i == _statusIndex;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 22, height: 22,
                                        decoration: BoxDecoration(
                                          color: isDone ? AppTheme.accent : (isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5)),
                                          shape: BoxShape.circle,
                                          border: isCurrent ? Border.all(color: AppTheme.accent, width: 2) : null,
                                        ),
                                        child: isDone ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
                                      ),
                                      if (i < _statuses.length - 1)
                                        Container(
                                          width: 2, height: 16,
                                          color: i < _statusIndex ? AppTheme.accent : AppTheme.divider(context),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _statuses[i],
                                    style: TextStyle(
                                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 14,
                                      color: isDone ? AppTheme.textPrimary(context) : AppTheme.textSecondary(context),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isDone)
                                    Text(
                                      _getStatusTime(i),
                                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context)),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cancel button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          side: BorderSide(color: AppTheme.errorRed.withOpacity(0.5)),
                        ),
                        child: const Text('Cancel Booking'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusTime(int index) {
    final now = DateTime.now();
    final times = [
      DateTime(now.year, now.month, now.day, now.hour, now.minute - 10),
      DateTime(now.year, now.month, now.day, now.hour, now.minute - 9),
      DateTime(now.year, now.month, now.day, now.hour, now.minute - 2),
    ];
    if (index < times.length) {
      final t = times[index];
      return '${t.hour}:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';
    }
    return '';
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel? The worker is already on the way.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Booking')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); context.go('/dashboard/user'); },
            child: Text('Cancel', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }
}

/// Pulsing blue dot for client location
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48 * _ctrl.value + 12,
            height: 48 * _ctrl.value + 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.15 * (1 - _ctrl.value)),
            ),
          ),
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color, border: Border.all(color: Colors.white, width: 2.5)),
          ),
        ],
      ),
    );
  }
}

/// Worker marker — circular with initial and status ring
class _WorkerMarker extends StatelessWidget {
  final String name;
  final bool arrived;
  const _WorkerMarker({required this.name, required this.arrived});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46, height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: arrived ? AppTheme.accent : AppTheme.secondary,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: (arrived ? AppTheme.accent : AppTheme.secondary).withOpacity(0.4), blurRadius: 12)],
      ),
      child: Center(
        child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
    );
  }
}

/// Small circular action button
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
