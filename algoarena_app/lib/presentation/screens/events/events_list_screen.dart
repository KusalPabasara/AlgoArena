import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/event.dart';
import '../../../data/repositories/event_repository.dart';
import '../../widgets/event_card.dart';
import '../../widgets/app_bottom_nav.dart';

/// Events List Screen - Matches Figma design 352:2301, 352:1796
class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final _eventRepository = EventRepository();
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventRepository.getAllEvents();
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load events: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleJoinEvent(Event event) async {
    try {
      final updatedEvent = await _eventRepository.toggleJoinEvent(
        event.id,
        !event.isJoined,
      );

      if (mounted) {
        setState(() {
          final index = _events.indexWhere((e) => e.id == event.id);
          if (index != -1) {
            _events[index] = updatedEvent;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedEvent.isJoined
                  ? 'Successfully joined ${event.title}'
                  : 'Left ${event.title}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update event: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _openEventDetail(Event event) {
    Navigator.pushNamed(
      context,
      '/event-detail',
      arguments: event.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative Bubbles Background (matches Figma)
          Positioned(
            left: -211.13,
            top: -331.84,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: 884.181,
                height: 1300.062,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),

                      const SizedBox(width: 16),

                      // Title
                      const Text(
                        'Events',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w700,
                          fontSize: 50,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Events List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _events.isEmpty
                          ? const Center(
                              child: Text(
                                'No events available',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 52),
                              child: ListView.separated(
                                itemCount: _events.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 26),
                                itemBuilder: (context, index) {
                                  final event = _events[index];
                                  return EventCard(
                                    event: event,
                                    onTap: () => _openEventDetail(event),
                                    onJoinToggle: () => _toggleJoinEvent(event),
                                  );
                                },
                              ),
                            ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Status Bar (positioned at top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 48,
              color: Colors.transparent,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      TimeOfDay.now().format(context),
                      style: const TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.black,
                        letterSpacing: 0.0039,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      children: [
                        // Cellular
                        Icon(Icons.signal_cellular_4_bar,
                            size: 16, color: AppColors.black),
                        const SizedBox(width: 4),
                        // WiFi
                        Icon(Icons.wifi, size: 16, color: AppColors.black),
                        const SizedBox(width: 4),
                        // Battery
                        Icon(Icons.battery_full,
                            size: 16, color: AppColors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: const AppBottomNav(currentIndex: 2), // Calendar tab
    );
  }
}
