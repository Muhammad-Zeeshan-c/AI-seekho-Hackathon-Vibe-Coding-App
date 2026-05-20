import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Callback signature invoked whenever the worker's simulated position changes
typedef TrackingCallback = void Function(LatLng position, double etaMinutes, String status);

/// Simulates a worker moving along a route towards the client's location.
class TrackingSimulator {
  final LatLng workerStart;
  final LatLng clientLocation;
  final int numPoints;

  TrackingSimulator({
    required this.workerStart,
    required this.clientLocation,
    this.numPoints = 15,
  });

  Timer? _timer;
  int _currentWaypointIndex = 0;
  List<LatLng> _waypoints = [];
  
  List<LatLng> get routePoints => _waypoints;

  /// Generates 15 linear interpolation coordinates between start and end.
  List<LatLng> _generateRouteWaypoints(LatLng start, LatLng end, {int steps = 15}) {
    final List<LatLng> points = [];
    for (int i = 0; i <= steps; i++) {
      final double fraction = i / steps;
      final double lat = start.latitude + (end.latitude - start.latitude) * fraction;
      final double lng = start.longitude + (end.longitude - start.longitude) * fraction;
      points.add(LatLng(lat, lng));
    }
    return points;
  }

  /// Starts the live tracking simulation, firing the callback every 3 seconds
  void startSimulation(void Function(LatLng pos, double eta) onUpdate) {
    stopSimulation();
    
    _waypoints = _generateRouteWaypoints(workerStart, clientLocation, steps: numPoints);
    _currentWaypointIndex = 0;

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentWaypointIndex < _waypoints.length) {
        final currentPosition = _waypoints[_currentWaypointIndex];
        
        // Calculate remaining ETA dynamically
        final double remainingFraction = 1.0 - (_currentWaypointIndex / (_waypoints.length - 1));
        final double etaMinutes = (remainingFraction * 12.0).clamp(0.5, 12.0);
        
        onUpdate(currentPosition, double.parse(etaMinutes.toStringAsFixed(1)));
        _currentWaypointIndex++;
      } else {
        stopSimulation();
        onUpdate(clientLocation, 0.0);
      }
    });
  }

  /// Stops the active simulation timer
  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
  }
}
