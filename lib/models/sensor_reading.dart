class SensorReading {
  final int lightIntensity;
  final String status;
  final String ledState;
  final DateTime createdAt;

  SensorReading({
    required this.lightIntensity,
    required this.status,
    required this.ledState,
    required this.createdAt,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      lightIntensity: json['light_intensity'] ?? 0,
      status: json['status'] ?? 'OFF',
      ledState: json['led_state'] ?? 'UNKNOWN',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
    );
  }

  String get conditionLabel {
    if (lightIntensity > 70) return 'Bright Day';
    if (lightIntensity >= 30) return 'Twilight';
    if (lightIntensity >= 15) return 'Dark Night';
    return 'Very Dark';
  }

  // Returns the color associated with current condition
  // green=bright, blue=twilight, red=dark/very dark
  String get ledColor {
    switch (ledState) {
      case 'Green':
        return 'green';
      case 'Blue':
        return 'blue';
      case 'Red':
      case 'RED_BLINK':
        return 'red';
      default:
        return 'grey';
    }
  }
}
