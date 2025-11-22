# Memory Optimization Plan for AlgoArena App

## 📊 Current Memory Issues Identified

### 1. **Animation Controllers (CRITICAL)**
**Issue:** Multiple AnimationControllers with `repeat()` that run indefinitely
- **Found in:**
  - `home_screen.dart`: `_bubbleController` with `repeat(reverse: true)` - never stops
  - `splash_screen.dart`: `_dotsController` with `repeat(reverse: true)` - never stops
  - `create_post_screen.dart`: `_bubbleController` with `repeat(reverse: true)` - never stops
  - `pages_screen.dart`: `_bubblesController` with `repeat()` - never stops
  - `notifications_screen.dart`: `_bubblesController` with `repeat()` - never stops
  - `search_screen.dart`: `_bubbleController` with `repeat()` - never stops

**Impact:** Each repeating animation controller consumes memory and CPU continuously, even when screen is not visible.

### 2. **Image Caching (HIGH PRIORITY)**
**Issue:** No cache size limits or memory management for images
- `CachedNetworkImage` used without cache configuration
- No max cache size limits
- No cache eviction strategy
- Images loaded at full resolution without compression
- Multiple large PNG assets (lion images, logos, etc.)

**Impact:** Images accumulate in memory cache indefinitely, causing memory bloat.

### 3. **List Rendering (HIGH PRIORITY)**
**Issue:** Loading all posts at once without pagination
- `home_screen.dart`: Loads all posts in `_loadData()` - no pagination
- `_posts.take(3)` only shows 3 but loads all
- No lazy loading or virtualization

**Impact:** All post data and images loaded into memory even if not displayed.

### 4. **Multiple Simultaneous Animations (MEDIUM)**
**Issue:** Many screens have 3-10+ AnimationControllers running simultaneously
- `register_screen.dart`: 11 AnimationControllers
- `password_recovery_screen.dart`: 5+ AnimationControllers
- Multiple screens with overlapping animations

**Impact:** Each controller consumes memory and processing power.

### 5. **Large Asset Files (MEDIUM)**
**Issue:** Unoptimized image assets
- Multiple PNG files without compression
- No WebP format usage
- Large splash screen images (lion_frame1.png, lion_frame2.png, etc.)

**Impact:** Assets loaded into memory at app startup consume significant memory.

### 6. **TextEditingController Management (LOW)**
**Issue:** Some controllers may not be properly disposed
- Most are disposed correctly, but need verification

### 7. **Provider State Management (LOW)**
**Issue:** Providers may hold large data sets
- `PostProvider` holds all posts in memory
- No data cleanup or pagination in providers

---

## 🎯 Optimization Strategy

### Phase 1: Critical Fixes (Immediate Impact)

#### 1.1 Stop Animations When Not Visible
**Priority: CRITICAL**

**Solution:** Pause/resume animations based on widget visibility

**Files to Update:**
- `home_screen.dart`
- `splash_screen.dart`
- `create_post_screen.dart`
- `pages_screen.dart`
- `notifications_screen.dart`
- `search_screen.dart`

**Implementation:**
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused || 
      state == AppLifecycleState.inactive) {
    _bubbleController.stop();
  } else if (state == AppLifecycleState.resumed) {
    _bubbleController.repeat(reverse: true);
  }
}

// Or use AutomaticKeepAliveClientMixin
// Or use VisibilityDetector package
```

#### 1.2 Configure Image Cache Limits
**Priority: CRITICAL**

**Solution:** Set cache size limits and eviction policies

**Implementation:**
```dart
// In main.dart or app initialization
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() {
  // Configure image cache
  PaintingBinding.instance.imageCache.maximumSize = 100; // Max 100 images
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB
  
  runApp(const AlgoArenaApp());
}
```

**Update CachedNetworkImage usage:**
```dart
CachedNetworkImage(
  imageUrl: url,
  cacheManager: CacheManager(
    Config(
      'customCacheKey',
      maxNrOfCacheObjects: 100,
      stalePeriod: const Duration(days: 7),
    ),
  ),
  memCacheWidth: 800, // Limit memory cache width
  memCacheHeight: 800, // Limit memory cache height
  maxWidthDiskCache: 1200, // Limit disk cache size
  maxHeightDiskCache: 1200,
)
```

#### 1.3 Implement Pagination for Posts
**Priority: HIGH**

**Solution:** Load posts in batches with lazy loading

**Files to Update:**
- `home_screen.dart`
- `post_repository.dart`
- `post_provider.dart`

**Implementation:**
```dart
// Use ListView.builder with pagination
ListView.builder(
  itemCount: _posts.length + (_hasMore ? 1 : 0),
  itemBuilder: (context, index) {
    if (index == _posts.length) {
      _loadMorePosts();
      return const LoadingIndicator();
    }
    return PostCard(post: _posts[index]);
  },
)

// Add scroll listener
ScrollController _scrollController = ScrollController();

_scrollController.addListener(() {
  if (_scrollController.position.pixels >= 
      _scrollController.position.maxScrollExtent * 0.8) {
    _loadMorePosts();
  }
});
```

---

### Phase 2: High Impact Optimizations

#### 2.1 Optimize Asset Images
**Priority: HIGH**

**Actions:**
1. Convert PNG to WebP format (50-70% size reduction)
2. Compress remaining PNG files
3. Use appropriate image sizes for different screen densities
4. Remove unused assets

**Tools:**
- Use `flutter_image_compress` package
- Use online tools like TinyPNG
- Use WebP format for Android

#### 2.2 Implement Image Compression
**Priority: HIGH**

**Solution:** Compress images before displaying

**Implementation:**
```dart
// Add to pubspec.yaml
dependencies:
  flutter_image_compress: ^2.0.0

// Compress images before caching
Future<File> compressImage(File file) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    file.absolute.path + '_compressed.jpg',
    quality: 85,
    minWidth: 1920,
    minHeight: 1080,
  );
  return File(result!.path);
}
```

#### 2.3 Reduce Animation Controllers
**Priority: MEDIUM**

**Solution:** 
- Combine similar animations
- Use single controller with multiple animations
- Remove unnecessary animations
- Use static widgets where animations aren't critical

**Example:**
```dart
// Instead of 3 separate controllers
late AnimationController _masterController;
late Animation<double> _fadeAnimation;
late Animation<Offset> _slideAnimation;
late Animation<double> _scaleAnimation;

// All use same controller with different intervals
```

#### 2.4 Implement Memory-Aware Widgets
**Priority: MEDIUM**

**Solution:** Use `AutomaticKeepAliveClientMixin` selectively

**Implementation:**
```dart
class _OptimizedWidgetState extends State<OptimizedWidget> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => false; // Don't keep alive if not needed
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required
    return YourWidget();
  }
}
```

---

### Phase 3: Advanced Optimizations

#### 3.1 Implement Image Lazy Loading
**Priority: MEDIUM**

**Solution:** Only load images when they're about to be visible

**Implementation:**
```dart
// Use visibility_detector package
VisibilityDetector(
  key: Key('image_$index'),
  onVisibilityChanged: (info) {
    if (info.visibleFraction > 0.5) {
      // Load image
    }
  },
  child: CachedNetworkImage(...),
)
```

#### 3.2 Add Memory Monitoring
**Priority: LOW**

**Solution:** Add memory profiling and monitoring

**Implementation:**
```dart
// Add dev_dependencies
dev_dependencies:
  flutter_memory_profiler: ^1.0.0

// Monitor memory usage
void _checkMemoryUsage() {
  final info = MemoryInfo();
  if (info.totalMemory > 100 * 1024 * 1024) { // 100MB
    // Clear caches
    imageCache.clear();
    imageCache.clearLiveImages();
  }
}
```

#### 3.3 Optimize Provider Usage
**Priority: LOW**

**Solution:** 
- Clear provider data when not needed
- Use `dispose()` methods in providers
- Implement data pagination in providers

---

## 📋 Implementation Checklist

### Immediate (Week 1)
- [ ] Stop animations when screens are not visible
- [ ] Configure image cache limits (50MB max, 100 images max)
- [ ] Add image compression for CachedNetworkImage
- [ ] Implement pagination for home screen posts
- [ ] Add scroll listener for lazy loading

### Short Term (Week 2)
- [ ] Convert PNG assets to WebP
- [ ] Compress remaining PNG files
- [ ] Reduce number of AnimationControllers per screen
- [ ] Add memory-aware widget mixins
- [ ] Implement image lazy loading

### Medium Term (Week 3-4)
- [ ] Add memory monitoring utilities
- [ ] Optimize provider data management
- [ ] Implement cache eviction strategies
- [ ] Add memory profiling tools
- [ ] Performance testing on low-end devices

---

## 🔧 Technical Implementation Details

### 1. Animation Lifecycle Management

**Create utility mixin:**
```dart
mixin AnimationLifecycleMixin<T extends StatefulWidget> on State<T> {
  List<AnimationController> get animationControllers;
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      for (var controller in animationControllers) {
        controller.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      for (var controller in animationControllers) {
        if (controller.isAnimating == false) {
          controller.repeat(reverse: true);
        }
      }
    }
  }
}
```

### 2. Image Cache Configuration

**Create image cache manager:**
```dart
// lib/core/utils/image_cache_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheManager {
  static const int maxCacheSize = 100;
  static const int maxCacheBytes = 50 * 1024 * 1024; // 50MB
  
  static void configure() {
    PaintingBinding.instance.imageCache.maximumSize = maxCacheSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes = maxCacheBytes;
  }
  
  static void clearCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }
  
  static CacheManager getCacheManager() {
    return CacheManager(
      Config(
        'algoarena_images',
        maxNrOfCacheObjects: maxCacheSize,
        stalePeriod: const Duration(days: 7),
        repo: JsonCacheInfoRepository(databaseName: 'algoarena_cache'),
      ),
    );
  }
}
```

### 3. Pagination Implementation

**Update PostRepository:**
```dart
Future<List<Post>> getFeed({
  int page = 1,
  int limit = 10,
}) async {
  final response = await _apiService.get(
    '/posts/feed',
    queryParameters: {
      'page': page,
      'limit': limit,
    },
  );
  // ... rest of implementation
}
```

**Update HomeScreen:**
```dart
int _currentPage = 1;
bool _hasMore = true;
final ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
  _loadPosts();
}

void _onScroll() {
  if (_scrollController.position.pixels >= 
      _scrollController.position.maxScrollExtent * 0.8) {
    if (!_isLoading && _hasMore) {
      _loadMorePosts();
    }
  }
}

Future<void> _loadMorePosts() async {
  setState(() => _isLoading = true);
  final newPosts = await _postRepository.getFeed(page: _currentPage + 1);
  if (newPosts.isEmpty) {
    _hasMore = false;
  } else {
    setState(() {
      _posts.addAll(newPosts);
      _currentPage++;
    });
  }
  setState(() => _isLoading = false);
}
```

---

## 📊 Expected Results

### Memory Reduction Targets:
- **Before:** ~150-200MB typical usage
- **After Phase 1:** ~80-120MB (40-50% reduction)
- **After Phase 2:** ~50-80MB (60-70% reduction)
- **After Phase 3:** ~40-60MB (70-80% reduction)

### Performance Improvements:
- Faster app startup (reduced asset loading)
- Smoother scrolling (lazy loading)
- Better battery life (fewer animations)
- Reduced crashes on low-end devices

---

## 🧪 Testing Strategy

1. **Memory Profiling:**
   - Use Flutter DevTools memory profiler
   - Test on low-end devices (2GB RAM)
   - Monitor memory usage over time
   - Check for memory leaks

2. **Performance Testing:**
   - Measure app startup time
   - Test scrolling performance
   - Monitor frame rates
   - Test on various devices

3. **User Testing:**
   - Test on real devices
   - Get feedback on performance
   - Monitor crash reports
   - Track memory-related issues

---

## 📝 Notes

- All changes should be backward compatible
- Test thoroughly before deploying
- Monitor memory usage in production
- Set up alerts for memory spikes
- Regular memory audits recommended

---

*Last Updated: [Current Date]*
*Version: 1.0*

