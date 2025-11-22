import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Image Cache Manager - Controls image caching to prevent memory bloat
class ImageCacheManager {
  /// Maximum number of images to cache in memory
  static const int maxCacheSize = 100;
  
  /// Maximum bytes to use for image cache (50MB)
  static const int maxCacheBytes = 50 * 1024 * 1024;
  
  /// Configure image cache limits
  static void configure() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = maxCacheSize;
    imageCache.maximumSizeBytes = maxCacheBytes;
  }
  
  /// Clear all cached images from memory
  static void clearCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();
  }
  
  /// Clear old cached images (keeps recent ones)
  static void clearOldCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clearLiveImages();
  }
  
  /// Get current cache statistics
  static Map<String, dynamic> getCacheStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': imageCache.currentSize,
      'currentSizeBytes': imageCache.currentSizeBytes,
      'maximumSize': imageCache.maximumSize,
      'maximumSizeBytes': imageCache.maximumSizeBytes,
    };
  }
  
  /// Get custom cache manager for network images
  static CacheManager getCacheManager() {
    return CacheManager(
      Config(
        'algoarena_images',
        maxNrOfCacheObjects: maxCacheSize,
        stalePeriod: const Duration(days: 7),
      ),
    );
  }
  
  /// Check if cache is getting full and clear if needed
  static void checkAndClearIfNeeded() {
    final imageCache = PaintingBinding.instance.imageCache;
    final usagePercent = (imageCache.currentSizeBytes / maxCacheBytes) * 100;
    
    // Clear cache if usage exceeds 80%
    if (usagePercent > 80) {
      clearOldCache();
    }
  }
}

