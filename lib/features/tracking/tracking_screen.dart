import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_providers.dart';
import '../../data/models/provider_model.dart';
import '../../data/services/tracking_simulator.dart';
import '../../data/services/log_service.dart';

/// Active tracking map displaying live worker coordinates moving to the client
class TrackingScreen extends StatefulWidget {
  final String bookingId;
  final String providerId;
  const TrackingScreen({super.key, required this.bookingId, required this.providerId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late ProviderModel _provider;
  final _mapController = MapController();
  final _simulator = TrackingSimulator();

  // Simulated live state
  LatLng _workerPosition = const LatLng(33.6844, 73.0479);
  final LatLng _clientPosition = const LatLng(33.6920, 73.0610); // slightly offset G-13 coordinate
  double _etaMinutes = 12.0;
  String _statusText = 'Worker departing';
  bool _arrived = false;

  @override
  void initState() {
    super.initState();
    _provider = MockProviderDatabase.providers.firstWhere(
      (p) => p.id == widget.providerId,
      orElse: () => MockProviderDatabase.providers.first,
    );
    // Worker starts at their mock location, client is at default coordinate
    _workerPosition = LatLng(_provider.lat, _provider.lng);

    _startTrackingSimulation();
  }

  @override
  void dispose() {
    _simulator.stopSimulation();
    super.dispose();
  }

  void _startTrackingSimulation() {
    _simulator.startSimulation(
      start: _workerPosition,
      end: _clientPosition,
      onUpdate: (position, eta, status) {
        setState(() {
          _workerPosition = position;
          _etaMinutes = eta;
          _statusText = status;
        });
        // Jitter map view occasionally to follow worker
        _mapController.move(position, 14.5);
        
        LogService.logEvent('TRACKING_COORDS_UPDATE', {
          'booking_id': widget.bookingId,
          'lat': position.latitude,
          'lng': position.longitude,
          'eta': eta,
        });
      },
      onArrival: () {
        setState(() {
          _arrived = true;
          _statusText = 'Worker Arrived!';
          _etaMinutes = 0;
        });
        LogService.logEvent('TRACKING_WORKER_ARRIVED', {
          'booking_id': widget.bookingId,
        });
        _showArrivalDialog();
      },
    );
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            'Worker Arrived! 🎉',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Aap ka worker pohanch chuka hai. Please kaam mukammal honay par rate aur review karein.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.pop(); // close dialog
                context.push('/feedback/${widget.bookingId}');
              },
              child: const Text('Complete & Review / جائزہ لیں'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap container via flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _workerPosition,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kaamkaar.app',
              ),
              
              // Polyline connecting worker to client
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_workerPosition, _clientPosition],
                    strokeWidth: 4,
                    color: AppTheme.primary,
                  ),
                ],
              ),
              
              // Markers Layer
              MarkerLayer(
                markers: [
                  // Client Marker
                  Marker(
                    point: _clientPosition,
                    width: 45,
                    height: 45,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      padding: const EdgeInsets.all(4),
                      child: const CircleAvatar(
                        backgroundColor: AppTheme.accent,
                        child: Icon(Icons.home_filled, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  
                  // Worker Marker
                  Marker(
                    point: _workerPosition,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: CircleAvatar(
                        backgroundColor: AppTheme.primary,
                        child: Text(
                          _provider.name[0],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top Header overlay
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking ID: ${widget.bookingId}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Status: $_statusText',
                          style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.terminal_rounded, color: AppTheme.aiPurple),
                    tooltip: 'View Agent trace',
                    onPressed: () => context.push('/logs'),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Worker Info sheet
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        radius: 26,
                        child: Text(_provider.name[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _provider.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              _provider.category,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Dynamic ETA Counter
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _etaMinutes.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 18),
                            ),
                            const Text(
                              'mins ETA',
                              style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 30),
                  
                  Row(
                    children: [
                      // Report Scam Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/report?bookingId=${widget.bookingId}&providerId=${_provider.id}'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorRed,
                            side: const BorderSide(color: AppTheme.errorRed),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('⚠️ Report Scam'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Cancel Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _simulator.stopSimulation();
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking Cancelled / آرڈر منسوخ کر دیا گیا')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: const Text('Cancel Job'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms),
        ],
      ),
    );
  }
}
