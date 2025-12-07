import 'package:flutter/foundation.dart';
import '../data/repositories/page_repository.dart';

/// Provider to manage page follow status globally
/// This ensures real-time updates across all screens
class PageFollowProvider extends ChangeNotifier {
  final PageRepository _pageRepository = PageRepository();
  
  // Map to store follow status: pageId -> isFollowing
  final Map<String, bool> _followStatus = {};
  
  // Map to store follower counts: pageId -> count
  final Map<String, int> _followerCounts = {};
  
  // Map to track pages that are currently being toggled
  final Set<String> _togglingPages = {};

  // Cache timestamps: pageId -> last loaded time
  final Map<String, DateTime> _lastStatusLoaded = {};
  final Map<String, DateTime> _lastCountLoaded = {};

  // TTL for cache (in seconds)
  static const int _statusTtlSeconds = 60;
  static const int _countTtlSeconds = 60;
  
  /// Get follow status for a page
  bool isFollowing(String pageId) {
    return _followStatus[pageId] ?? false;
  }
  
  /// Get follower count for a page
  int getFollowerCount(String pageId) {
    return _followerCounts[pageId] ?? 0;
  }
  
  /// Get all page IDs that the user is following
  Set<String> getFollowedPageIds() {
    return _followStatus.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toSet();
  }
  
  /// Check if a page is currently being toggled
  bool isToggling(String pageId) {
    return _togglingPages.contains(pageId);
  }
  
  /// Load follow status for a page
  Future<void> loadFollowStatus(String pageId) async {
    // If we already have fresh data in cache, skip network call
    final lastLoaded = _lastStatusLoaded[pageId];
    if (lastLoaded != null) {
      final age = DateTime.now().difference(lastLoaded).inSeconds;
      if (age < _statusTtlSeconds) {
        if (kDebugMode) {
          print('Using cached follow status for $pageId (age: ${age}s)');
        }
        return;
      }
    }

    try {
      final isFollowing = await _pageRepository.getFollowStatus(pageId);
      _followStatus[pageId] = isFollowing;
      _lastStatusLoaded[pageId] = DateTime.now();
      notifyListeners();
    } catch (e) {
      // Default to false if loading fails
      _followStatus[pageId] = false;
      notifyListeners();
    }
  }
  
  /// Load follow statuses for multiple pages
  Future<void> loadFollowStatuses(List<String> pageIds) async {
    final futures = pageIds.map((pageId) => loadFollowStatus(pageId));
    await Future.wait(futures);
  }
  
  /// Load follower count for a page
  Future<void> loadFollowerCount(String pageId) async {
    // If we already have fresh data in cache, skip network call
    final lastLoaded = _lastCountLoaded[pageId];
    if (lastLoaded != null) {
      final age = DateTime.now().difference(lastLoaded).inSeconds;
      if (age < _countTtlSeconds) {
        if (kDebugMode) {
          print('Using cached follower count for $pageId (age: ${age}s)');
        }
        return;
      }
    }

    try {
      final stats = await _pageRepository.getPageStats(pageId);
      _followerCounts[pageId] = stats['followersCount'] ?? 0;
      _lastCountLoaded[pageId] = DateTime.now();
      notifyListeners();
    } catch (e) {
      // Keep existing count if loading fails
      print('Error loading follower count for $pageId: $e');
    }
  }
  
  /// Toggle follow status for a page
  Future<bool> toggleFollow(String pageId) async {
    if (_togglingPages.contains(pageId)) {
      return _followStatus[pageId] ?? false;
    }
    
    _togglingPages.add(pageId);
    notifyListeners();
    
    try {
      final result = await _pageRepository.toggleFollow(pageId);
      final isFollowing = result['isFollowing'] ?? false;
      final followersCount = result['followersCount'] ?? 0;
      
      _followStatus[pageId] = isFollowing;
      _followerCounts[pageId] = followersCount;
      
      _togglingPages.remove(pageId);
      notifyListeners();
      
      return isFollowing;
    } catch (e) {
      _togglingPages.remove(pageId);
      notifyListeners();
      rethrow;
    }
  }
  
  /// Set follow status directly (for immediate UI updates)
  void setFollowStatus(String pageId, bool isFollowing, {int? followersCount}) {
    _followStatus[pageId] = isFollowing;
    if (followersCount != null) {
      _followerCounts[pageId] = followersCount;
    }
    notifyListeners();
  }
  
  /// Clear all follow status (e.g., on logout)
  void clear() {
    _followStatus.clear();
    _followerCounts.clear();
    _togglingPages.clear();
    notifyListeners();
  }
}

