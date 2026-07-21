import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sensor_reading.dart';
import '../services/supabase_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = SupabaseService();

  SensorReading? _latest;
  List<SensorReading> _history = [];
  bool _loading = true;
  String? _error;
  bool _refreshing = false;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _load();
    _channel = _service.subscribe(onNew: (reading) {
      if (mounted) {
        setState(() {
          _latest = reading;
          _history = [reading, ..._history].take(10).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final latest = await _service.fetchLatest();
      final history = await _service.fetchHistory();
      if (mounted) setState(() { _latest = latest; _history = history; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await _load();
    if (mounted) setState(() => _refreshing = false);
  }

  // Color for each condition
  Color _dotColor(String ledColor) {
    switch (ledColor) {
      case 'green': return Colors.green;
      case 'blue':  return Colors.blue;
      case 'red':   return Colors.red;
      default:      return Colors.grey;
    }
  }

  Color _conditionColor(SensorReading r) => _dotColor(r.ledColor);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Could not connect', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              FilledButton(onPressed: _load, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }

    final r = _latest;
    final intensity = r?.lightIntensity ?? 0;
    final condColor = r != null ? _conditionColor(r) : Colors.grey;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ──────────────────────────────────────────
              Row(
                children: [
                  const Text('Street Light',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6,
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('Live', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Gauge card ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 180,
                      height: 110,
                      child: CustomPaint(
                        painter: _GaugePainter(
                          percent: intensity / 100.0,
                          color: condColor,
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('$intensity%',
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Light intensity',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: condColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r?.conditionLabel ?? '—',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: condColor),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Two stat cards ──────────────────────────────────
              Row(
                children: [
                  Expanded(child: _StatCard(
                    label: 'Street light',
                    value: r?.status ?? '—',
                    sub: 'Auto-managed',
                    valueColor: r?.status == 'ON' ? Colors.orange : Colors.grey,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    label: 'RGB state',
                    value: r?.ledState == 'RED_BLINK' ? 'Red blink' : (r?.ledState ?? '—'),
                    sub: r?.conditionLabel ?? '',
                    valueColor: condColor,
                  )),
                ],
              ),

              const SizedBox(height: 20),

              // ── Recent readings ─────────────────────────────────
              const Text('Recent readings',
                style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _history.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text('No data yet', style: TextStyle(color: Colors.grey))),
                      )
                    : Column(
                        children: _history.asMap().entries.map((entry) {
                          final i = entry.key;
                          final row = entry.value;
                          final color = _dotColor(row.ledColor);
                          return Column(
                            children: [
                              if (i > 0)
                                Divider(height: 1, color: Theme.of(context).dividerColor),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(width: 8, height: 8,
                                      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                    const SizedBox(width: 10),
                                    Text(
                                      DateFormat('HH:mm:ss').format(row.createdAt),
                                      style: const TextStyle(fontSize: 13, color: Colors.grey,
                                        fontFeatures: [FontFeature.tabularFigures()]),
                                    ),
                                    const Spacer(),
                                    Text('${row.lightIntensity}%',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 36,
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      decoration: BoxDecoration(
                                        color: row.status == 'ON'
                                            ? Colors.orange.withOpacity(0.12)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(row.status,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: row.status == 'ON' ? Colors.orange : Colors.grey,
                                        )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 16),

              // ── Refresh button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _refreshing ? null : _refresh,
                  icon: _refreshing
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Gauge painter ─────────────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color color;
  _GaugePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 12.0;
    final radius = size.width / 2 - 10;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      math.pi, math.pi, false,
      Paint()
        ..color = Colors.grey.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    // Fill
    if (percent > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        math.pi, math.pi * percent, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.percent != percent || old.color != color;
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: valueColor)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
