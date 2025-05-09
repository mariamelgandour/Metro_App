class Station {
  final String name;
  final List<String> neighbors;
  final double lat; // الإحداثيات الجغرافية
  final double lng; // الإحداثيات الجغرافية
  double x; // الـ offset على الصورة
  double y; // الـ offset على الصورة

  Station({
    required this.name,
    required this.neighbors,
    required this.lat,
    required this.lng,
    required this.x,
    required this.y,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      name: json['name'],
      neighbors: List<String>.from(json['neighbors']),
      lat: json['lat'], // إضافة lat
      lng: json['lng'], // إضافة lng
      x: json['x'],
      y: json['y'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'neighbors': neighbors,
      'lat': lat,
      'lng': lng,
      'x': x,
      'y': y,
    };
  }
}
