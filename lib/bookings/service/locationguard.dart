import 'package:flutter/material.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'dart:math' show cos, sqrt, asin;

/// A reusable widget that wraps any child widget and only displays it
/// when the user is within a specified radius of a target location.
///
/// Usage:
/// ```dart
/// LocationGuard(
///   targetLatitude: 12.3456,
///   targetLongitude: 78.9012,
///   radiusInMeters: 100.0,
///   child: YourWidget(),
///   loadingWidget: CircularProgressIndicator(),
///   errorWidget: Text('Location error'),
/// )
/// ```
class LocationGuard extends StatefulWidget {
  /// The latitude of the target location
  final double targetLatitude;

  /// The longitude of the target location
  final double targetLongitude;

  /// The maximum allowed distance in meters (default: 100m)
  final double radiusInMeters;

  /// The widget to display when within range
  final Widget child;

  /// Custom loading widget (optional)
  final Widget? loadingWidget;

  /// Custom error widget when location fetch fails (optional)
  final Widget? errorWidget;

  /// Custom out of range widget (optional)
  final Widget? outOfRangeWidget;

  /// Whether to show distance information (default: true)
  final bool showDistance;

  /// Whether to auto-refresh location periodically (default: false)
  final bool autoRefresh;

  /// Refresh interval in seconds (default: 30)
  final int refreshIntervalSeconds;

  /// Callback when location status changes
  final Function(bool isWithinRange, double distance)? onLocationStatusChanged;

  const LocationGuard({
    Key? key,
    required this.targetLatitude,
    required this.targetLongitude,
    required this.child,
    this.radiusInMeters = 100.0,
    this.loadingWidget,
    this.errorWidget,
    this.outOfRangeWidget,
    this.showDistance = true,
    this.autoRefresh = false,
    this.refreshIntervalSeconds = 30,
    this.onLocationStatusChanged,
  }) : super(key: key);

  @override
  State<LocationGuard> createState() => _LocationGuardState();
}

class _LocationGuardState extends State<LocationGuard> {
  Map<String, double>? _caretakerLocation;
  bool _isLoading = true;
  bool _hasError = false;
  double _currentDistance = 0.0;
  bool _isWithinRange = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();

    // Setup auto-refresh if enabled
    if (widget.autoRefresh) {
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    Future.delayed(Duration(seconds: widget.refreshIntervalSeconds), () {
      if (mounted) {
        _fetchLocation();
        _startAutoRefresh();
      }
    });
  }

  Future<void> _fetchLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final location = await LocationService.getCurrentCoordinates();

      if (location != null) {
        _caretakerLocation = location;
        _calculateDistance();
        _hasError = false;
      } else {
        _hasError = true;
      }
    } catch (e) {
      debugPrint("❌ LocationGuard: Error fetching location: $e");
      _hasError = true;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _calculateDistance() {
    if (_caretakerLocation == null) return;

    _currentDistance = _haversineDistance(
      _caretakerLocation!['lat']!,
      _caretakerLocation!['lng']!,
      widget.targetLatitude,
      widget.targetLongitude,
    );

    _isWithinRange = _currentDistance <= widget.radiusInMeters;

    // Trigger callback if provided
    widget.onLocationStatusChanged?.call(_isWithinRange, _currentDistance);

    debugPrint(
      "📍 LocationGuard: Distance ${_currentDistance.toStringAsFixed(0)}m | Within range: $_isWithinRange",
    );
  }

  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        (_sin(dLat / 2) * _sin(dLat / 2)) +
        (_cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2));

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.141592653589793 / 180);

  double _sin(double x) {
    double sum = 0;
    double term = x;
    for (int n = 1; n <= 10; n++) {
      sum += term;
      term *= -x * x / ((2 * n) * (2 * n + 1));
    }
    return sum;
  }

  double _cos(double x) {
    double sum = 1;
    double term = 1;
    for (int n = 1; n <= 10; n++) {
      term *= -x * x / ((2 * n - 1) * (2 * n));
      sum += term;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Loading state
    if (_isLoading) {
      return widget.loadingWidget ?? _buildDefaultLoading(size);
    }

    // Error state
    if (_hasError || _caretakerLocation == null) {
      return widget.errorWidget ?? _buildDefaultError(size);
    }

    // Out of range state
    if (!_isWithinRange) {
      return widget.outOfRangeWidget ?? _buildDefaultOutOfRange(size);
    }

    // Within range - show the child widget
    return Column(
      children: [
        if (widget.showDistance) _buildDistanceInfo(size),
        widget.child,
      ],
    );
  }

  Widget _buildDefaultLoading(Size size) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 12),
          Text(
            "Checking your location...",
            style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultError(Size size) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_searching, color: AppColors.error, size: 32),
          SizedBox(height: 12),
          Text(
            "Unable to fetch your location",
            style: AppTextStyles.body.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _fetchLocation,
            icon: Icon(Icons.refresh, size: 16),
            label: Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultOutOfRange(Size size) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, color: AppColors.error, size: 32),
          SizedBox(height: 12),
          Text(
            "You are too far from the required location",
            style: AppTextStyles.body.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Distance: ${_currentDistance.toStringAsFixed(0)}m\nRequired: within ${widget.radiusInMeters.toStringAsFixed(0)}m",
            style: AppTextStyles.small.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _fetchLocation,
            icon: Icon(Icons.refresh, size: 16),
            label: Text("Refresh Location"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceInfo(Size size) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.success),
          SizedBox(width: 8),
          Text(
            "You are at the location (${_currentDistance.toStringAsFixed(0)}m away)",
            style: AppTextStyles.small.copyWith(
              color: AppColors.success,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 8),
          InkWell(
            onTap: _fetchLocation,
            child: Icon(Icons.refresh, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
