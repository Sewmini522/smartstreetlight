import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sensor_reading.dart';

class SupabaseService {
  static const String _url = 'https://mrsixvtzgdulhkxbylto.supabase.co';
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yc2l4dnR6Z2R1bGhreGJ5bHRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM1MTQ0MjcsImV4cCI6MjA5OTA5MDQyN30.8JAmNQ3P8yDKwQnuUfCMXFCMV0vUzUJ2B64-eMsLVNk';

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  static SupabaseClient get _client => Supabase.instance.client;

  /// Fetch the latest single reading
  Future<SensorReading?> fetchLatest() async {
    final data = await _client
        .from('esp_data1')
        .select()
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return data == null ? null : SensorReading.fromJson(data);
  }

  /// Fetch last 10 readings for the log
  Future<List<SensorReading>> fetchHistory() async {
    final data = await _client
        .from('esp_data1')
        .select()
        .order('created_at', ascending: false)
        .limit(10);
    return (data as List).map((e) => SensorReading.fromJson(e)).toList();
  }

  /// Real-time subscription — fires on every new INSERT
  RealtimeChannel subscribe({
    required void Function(SensorReading) onNew,
  }) {
    return _client
        .channel('esp_data1_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'esp_data1',
          callback: (payload) => onNew(SensorReading.fromJson(payload.newRecord)),
        )
        .subscribe();
  }
}
