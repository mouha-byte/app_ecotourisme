import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for downloading and caching OpenStreetMap tiles for offline use
class OfflineMapService {
  static const String _cacheSizeKey = 'offline_map_cache_size';
  static const String _tilesDir = 'map_tiles';
  
  // Tunisia bounding box (approximate)
  static const double tunisiaMinLat = 30.0;
  static const double tunisiaMaxLat = 37.5;
  static const double tunisiaMinLng = 7.5;
  static const double tunisiaMaxLng = 11.6;
  
  /// Get the directory for storing cached tiles
  Future<Directory> _getTilesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final tilesDir = Directory('${appDir.path}/$_tilesDir');
    if (!await tilesDir.exists()) {
      await tilesDir.create(recursive: true);
    }
    return tilesDir;
  }

  /// Get the file path for a specific tile
  Future<String> _getTilePath(int z, int x, int y) async {
    final tilesDir = await _getTilesDirectory();
    return '${tilesDir.path}/$z/$x/$y.png';
  }

  /// Check if a tile is cached
  Future<bool> isTileCached(int z, int x, int y) async {
    final path = await _getTilePath(z, x, y);
    return File(path).exists();
  }

  /// Get the current cache size in bytes
  Future<int> getCacheSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cacheSizeKey) ?? 0;
  }

  /// Get formatted cache size string
  Future<String> getFormattedCacheSize() async {
    final bytes = await getCacheSize();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Clear all cached tiles
  Future<void> clearCache() async {
    try {
      final tilesDir = await _getTilesDirectory();
      if (await tilesDir.exists()) {
        await tilesDir.delete(recursive: true);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cacheSizeKey, 0);
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Convert latitude to tile Y coordinate
  int _latToTileY(double lat, int zoom) {
    final latRad = lat * math.pi / 180;
    final n = math.pow(2.0, zoom);
    return ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * n).floor();
  }

  /// Convert longitude to tile X coordinate
  int _lngToTileX(double lng, int zoom) {
    final n = math.pow(2.0, zoom);
    return ((lng + 180.0) / 360.0 * n).floor();
  }

  /// Calculate total number of tiles for a region
  int calculateTileCount({
    double minLat = tunisiaMinLat,
    double maxLat = tunisiaMaxLat,
    double minLng = tunisiaMinLng,
    double maxLng = tunisiaMaxLng,
    int minZoom = 6,
    int maxZoom = 12,
  }) {
    int totalTiles = 0;
    
    for (int z = minZoom; z <= maxZoom; z++) {
      final minX = _lngToTileX(minLng, z);
      final maxX = _lngToTileX(maxLng, z);
      final minY = _latToTileY(maxLat, z);
      final maxY = _latToTileY(minLat, z);
      
      totalTiles += (maxX - minX + 1) * (maxY - minY + 1);
    }
    
    return totalTiles;
  }

  /// Download map tiles for Tunisia region
  /// [onProgress] callback receives (downloaded, total) tiles count
  Future<bool> downloadTunisiaTiles({
    int minZoom = 6,
    int maxZoom = 12,
    Function(int downloaded, int total)? onProgress,
  }) async {
    try {
      final totalTiles = calculateTileCount(minZoom: minZoom, maxZoom: maxZoom);
      int downloadedTiles = 0;
      int totalBytes = 0;
      
      for (int z = minZoom; z <= maxZoom; z++) {
        final minX = _lngToTileX(tunisiaMinLng, z);
        final maxX = _lngToTileX(tunisiaMaxLng, z);
        final minY = _latToTileY(tunisiaMaxLat, z);
        final maxY = _latToTileY(tunisiaMinLat, z);
        
        for (int x = minX; x <= maxX; x++) {
          for (int y = minY; y <= maxY; y++) {
            // Skip if already cached
            if (await isTileCached(z, x, y)) {
              downloadedTiles++;
              onProgress?.call(downloadedTiles, totalTiles);
              continue;
            }
            
            try {
              final url = 'https://tile.openstreetmap.org/$z/$x/$y.png';
              final response = await http.get(
                Uri.parse(url),
                headers: {'User-Agent': 'EcoGuide/1.0'},
              );
              
              if (response.statusCode == 200) {
                final tilePath = await _getTilePath(z, x, y);
                final tileFile = File(tilePath);
                
                // Create directory if needed
                await tileFile.parent.create(recursive: true);
                await tileFile.writeAsBytes(response.bodyBytes);
                
                totalBytes += response.bodyBytes.length;
              }
            } catch (e) {
              debugPrint('Error downloading tile $z/$x/$y: $e');
            }
            
            downloadedTiles++;
            onProgress?.call(downloadedTiles, totalTiles);
            
            // Small delay to avoid rate limiting
            await Future.delayed(const Duration(milliseconds: 50));
          }
        }
      }
      
      // Update cache size
      final prefs = await SharedPreferences.getInstance();
      final currentSize = prefs.getInt(_cacheSizeKey) ?? 0;
      await prefs.setInt(_cacheSizeKey, currentSize + totalBytes);
      
      return true;
    } catch (e) {
      debugPrint('Error downloading tiles: $e');
      return false;
    }
  }

  /// Get cached tile file if available
  Future<File?> getCachedTile(int z, int x, int y) async {
    final path = await _getTilePath(z, x, y);
    final file = File(path);
    if (await file.exists()) {
      return file;
    }
    return null;
  }
}
