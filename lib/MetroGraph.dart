import 'dart:ui';
import 'Models/Station.dart';

class MetroGraph {
  final List<Station> stations;
  final Map<String, List<String>> stationLinesMap;
  final double minLat, maxLat, minLng, maxLng, imageWidth, imageHeight;

  MetroGraph({
    required this.stations,
    required this.stationLinesMap,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    required this.imageWidth,
    required this.imageHeight,
  });

  // تحويل lat, lng إلى offset
  Offset latLngToOffset(double lat, double lng) {
    double normalizedX = (lng - minLng) / (maxLng - minLng);
    double normalizedY = (lat - minLat) / (maxLat - minLat);

    // تحويل إلى النقاط المناسبة في الصورة
    double x = normalizedX * imageWidth;
    double y = (1 - normalizedY) * imageHeight; // لانه معكوس

    return Offset(x, y);
  }

  // جلب المحطة حسب الاسم
  Station? getStationByName(String name) => stations.firstWhere(
    (station) => station.name == name,
    orElse: () => throw Exception("Station with name '$name' not found."),
  );

  // إيجاد أقصر مسار بين محطتين باستخدام Dijkstra
  List<Station> findShortestPath(String start, String end) {
    final distances = <String, double>{};
    final previous = <String, String?>{};
    final unvisited = <String>{};

    for (final station in stations) {
      distances[station.name] = double.infinity;
      previous[station.name] = null;
      unvisited.add(station.name);
    }

    distances[start] = 0;

    while (unvisited.isNotEmpty) {
      final current = _getMinDistanceStation(unvisited, distances);
      if (current == end) break;

      unvisited.remove(current);

      final currentStation = getStationByName(current);
      if (currentStation == null) continue;

      for (final neighbor in currentStation.neighbors) {
        final newDist = distances[current]! + 1;
        if (newDist < (distances[neighbor] ?? double.infinity)) {
          distances[neighbor] = newDist;
          previous[neighbor] = current;
        }
      }
    }

    return _reconstructPath(previous, end);
  }

  // استرجاع المسار من الخريطة
  List<Station> _reconstructPath(Map<String, String?> previous, String end) {
    final path = <Station>[];
    String? current = end;

    while (current != null) {
      final station = getStationByName(current);
      if (station != null) path.insert(0, station);
      current = previous[current];
    }

    return path;
  }

  // إيجاد المحطة ذات أقل مسافة
  String _getMinDistanceStation(
    Set<String> unvisited,
    Map<String, double> distances,
  ) {
    return unvisited.reduce(
      (a, b) =>
          (distances[a] ?? double.infinity) < (distances[b] ?? double.infinity)
              ? a
              : b,
    );
  }

  // DFS لإيجاد جميع المسارات
  void _dfs(
    String current,
    String end,
    List<String> path,
    List<List<String>> result,
  ) {
    if (current == end) {
      result.add(List.from(path));
      return;
    }

    final currentStation = getStationByName(current);
    if (currentStation == null) return;

    for (final neighbor in currentStation.neighbors) {
      if (!path.contains(neighbor)) {
        path.add(neighbor);
        _dfs(neighbor, end, path, result);
        path.removeLast();
      }
    }
  }

  // إيجاد كل المسارات الممكنة
  List<List<Station>> findAllPaths(String start, String end) {
    final rawPaths = <List<String>>[];
    _dfs(start, end, [start], rawPaths);

    return rawPaths
        .map((path) => path.map((name) => getStationByName(name)!).toList())
        .toList();
  }

  // المحطات المشتركة بين المسارات
  Set<String> getSharedStationsAmongPaths(List<List<Station>> paths) {
    if (paths.isEmpty) return {};

    return paths
        .map((path) => path.map((s) => s.name).toSet())
        .reduce((a, b) => a.intersection(b));
  }

  // الخطوط التي تمر بمحطة معينة
  List<String> getLinesForStation(String name) => stationLinesMap[name] ?? [];

  // تحويل lat, lng إلى offset لجميع المحطات
  void updateStationsOffsets() {
    for (var station in stations) {
      final offset = latLngToOffset(station.lat, station.lng);
      station.x = offset.dx;
      station.y = offset.dy;
    }
  }

  // إيجاد المحطات التي تقع ضمن نطاق معين
  List<Station> getStationsInRegion(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) {
    return stations.where((station) {
      return station.lat >= minLat &&
          station.lat <= maxLat &&
          station.lng >= minLng &&
          station.lng <= maxLng;
    }).toList();
  }

  // تحديث المسار بين محطتين بحيث يشمل التحويل بين الخطوط
  List<Station> getPathWithLineChanges(String start, String end) {
    final path = findShortestPath(start, end);
    if (path.isEmpty) return path;

    List<Station> updatedPath = [path[0]];

    for (int i = 1; i < path.length; i++) {
      if (getLinesForStation(path[i].name) !=
          getLinesForStation(path[i - 1].name)) {
        // إضافة المحطة مع تغيير الخطوط
        updatedPath.add(path[i]);
      }
    }

    return updatedPath;
  }
}
