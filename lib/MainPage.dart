import 'package:flutter/material.dart';
import 'package:metro_app/ui/metro_path_painter.dart';
import 'package:metro_app/data/metro_lines.dart';
import 'MetroGraph.dart';
import 'Models/Station.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? _startStation;
  String? _endStation;

  late List<Station> stations;
  late Map<String, List<String>> stationLinesMap;
  late MetroGraph graph;

  List<Station> shortestPath = [];
  List<List<Station>> allPaths = [];

  @override
  void initState() {
    super.initState();
    _loadStations();

    // إعداد بيانات الحدود الجغرافية للصورة
    double minLat = stations.map((s) => s.lat).reduce((a, b) => a < b ? a : b);
    double maxLat = stations.map((s) => s.lat).reduce((a, b) => a > b ? a : b);
    double minLng = stations.map((s) => s.lng).reduce((a, b) => a < b ? a : b);
    double maxLng = stations.map((s) => s.lng).reduce((a, b) => a > b ? a : b);

    // إعداد الكائن MetroGraph بالحجم الصحيح للصورة (950x950)
    graph = MetroGraph(
      stations: stations,
      stationLinesMap: stationLinesMap,
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
      imageWidth: 950,
      imageHeight: 950,
    );

    updateStationsOffsets();
  }

  void _loadStations() {
    stations = [];
    stationLinesMap = {};

    void addLine(List<Map<String, dynamic>> line, String lineName) {
      for (int i = 0; i < line.length; i++) {
        final current = line[i];
        final name = current['name'];
        final lat = current['lat'];
        final lng = current['lng'];
        final prev = i > 0 ? line[i - 1]['name'] : null;
        final next = i < line.length - 1 ? line[i + 1]['name'] : null;

        final station = stations.firstWhere(
          (s) => s.name == name,
          orElse: () {
            final neighbors = <String>[
              if (prev != null) prev,
              if (next != null) next,
            ];
            final newStation = Station(
              name: name,
              lat: lat,
              lng: lng,
              neighbors: neighbors,
              x: 0,
              y: 0,
            );
            stations.add(newStation);
            return newStation;
          },
        );

        if (prev != null && !station.neighbors.contains(prev)) {
          station.neighbors.add(prev);
        }
        if (next != null && !station.neighbors.contains(next)) {
          station.neighbors.add(next);
        }

        stationLinesMap.putIfAbsent(name, () => []);
        if (!stationLinesMap[name]!.contains(lineName)) {
          stationLinesMap[name]!.add(lineName);
        }
      }
    }

    // تحميل الخطوط
    addLine(MetroLines.line1, "الخط الأول");
    addLine(MetroLines.line2, "الخط الثاني");
    addLine(MetroLines.line3, "الخط الثالث");
  }

  void _updatePaths() {
    if (_startStation != null && _endStation != null) {
      try {
        final shortest = graph.findShortestPath(_startStation!, _endStation!);
        final all = graph.findAllPaths(_startStation!, _endStation!);
        final shared = graph.getSharedStationsAmongPaths(all);

        setState(() {
          shortestPath = shortest;
          allPaths = all;
        });

        if (shared.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("محطات مشتركة: ${shared.join(", ")}"),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطأ: ${e.toString()}")));
      }
    }
  }

  void updateStationsOffsets() {
    for (var station in stations) {
      final offset = graph.latLngToOffset(station.lat, station.lng);
      station.x = offset.dx;
      station.y = offset.dy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stationNames = stations.map((s) => s.name).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('خريطة المترو'),
        backgroundColor: Colors.red.shade700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'محطة البداية'),
                  value: _startStation,
                  items:
                      stationNames
                          .map(
                            (station) => DropdownMenuItem(
                              value: station,
                              child: Text(station),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _startStation = value);
                    _updatePaths();
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'محطة النهاية'),
                  value: _endStation,
                  items:
                      stationNames
                          .map(
                            (station) => DropdownMenuItem(
                              value: station,
                              child: Text(station),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _endStation = value);
                    _updatePaths();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Image.asset(
                  'images/metro.jpg',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
                CustomPaint(
                  painter: MetroPathPainter(
                    shortestPath: shortestPath,
                    allPaths: allPaths,
                  ),
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
