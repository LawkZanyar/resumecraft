import 'dart:math' as math;

/// A point on Earth.
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

/// Great-circle distance in kilometres (haversine formula).
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(a));
}

/// Default sample center used before GPS is available.
const sampleCenter = GeoPoint(36.1911, 44.0092); // Erbil
const sampleCenterName = 'Erbil, Iraq';
