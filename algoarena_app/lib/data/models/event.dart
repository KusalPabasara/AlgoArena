class Event {
  final String id;
  final String title;
  final String eventName;
  final String organizer;
  final String date;
  final String month;
  final String imageUrl;
  final String? bannerImageUrl;
  final String? description;
  final bool isJoined;
  final EventColor colorTheme;
  final DateTime? eventDate; // Full event date for expiration checking
  final String? location; // Event location
  final String? category; // Event category

  Event({
    required this.id,
    required this.title,
    required this.eventName,
    required this.organizer,
    required this.date,
    required this.month,
    required this.imageUrl,
    this.bannerImageUrl,
    this.description,
    this.isJoined = false,
    this.colorTheme = EventColor.purple,
    this.eventDate,
    this.location,
    this.category,
  });
  
  // Check if event is expired
  bool get isExpired {
    if (eventDate == null) return false;
    return DateTime.now().isAfter(eventDate!);
  }
  
  // Check if event expired more than 2 days ago
  bool get shouldBeRemoved {
    if (eventDate == null || !isExpired) return false;
    final daysSinceExpiry = DateTime.now().difference(eventDate!).inDays;
    return daysSinceExpiry > 2;
  }

  Event copyWith({
    String? id,
    String? title,
    String? eventName,
    String? organizer,
    String? date,
    String? month,
    String? imageUrl,
    String? bannerImageUrl,
    String? description,
    bool? isJoined,
    EventColor? colorTheme,
    DateTime? eventDate,
    String? location,
    String? category,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      eventName: eventName ?? this.eventName,
      organizer: organizer ?? this.organizer,
      date: date ?? this.date,
      month: month ?? this.month,
      imageUrl: imageUrl ?? this.imageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      description: description ?? this.description,
      isJoined: isJoined ?? this.isJoined,
      colorTheme: colorTheme ?? this.colorTheme,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      category: category ?? this.category,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    // Parse event date to extract day and month
    String date = '1';
    String month = 'Jan';
    DateTime? parsedEventDate;
    if (json['eventDate'] != null) {
      try {
        // Handle Firestore timestamp format
        if (json['eventDate'] is Map && json['eventDate']['_seconds'] != null) {
          parsedEventDate = DateTime.fromMillisecondsSinceEpoch(
            json['eventDate']['_seconds'] * 1000,
          );
        } else if (json['eventDate'] is String) {
          parsedEventDate = DateTime.parse(json['eventDate']);
        } else if (json['eventDate'] is int) {
          // Handle Unix timestamp
          parsedEventDate = DateTime.fromMillisecondsSinceEpoch(json['eventDate'] * 1000);
        }
        
        if (parsedEventDate != null) {
          date = parsedEventDate.day.toString();
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          month = months[parsedEventDate.month - 1];
        }
      } catch (e) {
        // Use defaults if parsing fails
        print('Error parsing eventDate: $e');
      }
    }
    
    // Determine if user is participant
    final participants = json['participants'] as List<dynamic>? ?? [];
    final currentUserId = json['_currentUserId'] as String?; // Should be set by repository
    
    bool isJoined = false;
    
    // First check if backend explicitly provides isParticipant field
    if (json['isParticipant'] != null) {
      isJoined = json['isParticipant'] as bool;
    } else if (currentUserId != null) {
      // Check participants array
      if (participants.isNotEmpty) {
        // Handle both old format (string IDs) and new format (objects with userId)
        isJoined = participants.any((participant) {
          if (participant is String) {
            // Direct string comparison
            final matches = participant.toString().trim() == currentUserId.toString().trim();
            if (matches) {
              print('   ✅ Found match: String participant "$participant" == currentUserId "$currentUserId"');
            }
            return matches;
          } else if (participant is Map) {
            // Check multiple possible field names for user ID
            // Backend stores: { userId: userId, id: userId, name, email, phone, notes, joinedAt }
            final participantUserId = participant['userId'] ?? 
                                     participant['id'] ?? 
                                     participant['_id'];
            
            if (participantUserId != null) {
              // Convert both to strings and trim for comparison
              final participantIdStr = participantUserId.toString().trim();
              final currentUserIdStr = currentUserId.toString().trim();
              final matches = participantIdStr == currentUserIdStr;
              
              if (matches) {
                print('   ✅ Found match: Map participant userId="$participantIdStr" == currentUserId "$currentUserIdStr"');
              } else {
                // Debug: Log why it didn't match
                print('   ❌ No match: participant userId="$participantIdStr" (type: ${participantUserId.runtimeType}) != currentUserId "$currentUserIdStr" (type: ${currentUserId.runtimeType})');
              }
              return matches;
            } else {
              print('   ⚠️ Participant Map has no userId/id/_id fields. Keys: ${participant.keys.toList()}');
            }
          }
          return false;
        });
      }
      
      // Also check if currentUserId is in participantsCount or other fields
      // Some backends might return participantIds array
      if (!isJoined && json['participantIds'] != null) {
        final participantIds = json['participantIds'] as List<dynamic>? ?? [];
        isJoined = participantIds.contains(currentUserId);
      }
    }
    
    // Debug logging - ALWAYS log for ALL events when currentUserId is provided
    if (currentUserId != null) {
      final eventId = json['_id'] ?? json['id'] ?? 'unknown';
      if (isJoined) {
        print('✅✅✅ Event "$eventId": User "$currentUserId" is JOINED (participants: ${participants.length})');
      } else {
        print('❌❌❌ Event "$eventId": User "$currentUserId" is NOT JOINED (participants: ${participants.length})');
        if (participants.isNotEmpty) {
          print('   🔍 Checking participants for event "$eventId":');
          print('   Participant formats: ${participants.map((p) => p.runtimeType).toList()}');
          for (int i = 0; i < participants.length; i++) {
            final participant = participants[i];
            if (participant is Map) {
              final participantMap = participant;
              print('   Participant[$i] keys: ${participantMap.keys.toList()}');
              final userId = participantMap['userId'];
              final id = participantMap['id'];
              final _id = participantMap['_id'];
              print('   Participant[$i] userId="$userId" (type: ${userId?.runtimeType})');
              print('   Participant[$i] id="$id" (type: ${id?.runtimeType})');
              print('   Participant[$i] _id="$_id" (type: ${_id?.runtimeType})');
              print('   Participant[$i] currentUserId="$currentUserId" (type: ${currentUserId.runtimeType})');
              if (userId != null) {
                final userIdStr = userId.toString().trim();
                final currentUserIdStr = currentUserId.toString().trim();
                print('   Participant[$i] userId match: "$userIdStr" == "$currentUserIdStr" = ${userIdStr == currentUserIdStr}');
              }
              if (id != null) {
                final idStr = id.toString().trim();
                final currentUserIdStr = currentUserId.toString().trim();
                print('   Participant[$i] id match: "$idStr" == "$currentUserIdStr" = ${idStr == currentUserIdStr}');
              }
            } else if (participant is String) {
              final participantStr = participant.toString().trim();
              final currentUserIdStr = currentUserId.toString().trim();
              print('   Participant[$i] (String): "$participantStr" == "$currentUserIdStr" = ${participantStr == currentUserIdStr}');
            }
          }
        } else {
          print('   ⚠️ No participants in event "$eventId"');
        }
      }
    } else {
      print('⚠️⚠️⚠️ Event ${json['_id'] ?? json['id']}: currentUserId is NULL - cannot determine join status');
    }
    
    // Get organizer name
    String organizer = json['organizerName'] as String? ?? 
                      json['organizer']?['fullName'] as String? ?? 
                      json['organizer'] as String? ?? 
                      'Unknown Organizer';
    
    // Get event name (use description as subtitle, fallback to title if description not available)
    String eventName = json['eventName'] as String? ?? 
                      json['description'] as String? ?? 
                      json['title'] as String? ?? '';
    
    // Get image URL (use page logo for avatar, fallback to banner image)
    String imageUrl = json['pageLogo'] as String? ??
                     json['bannerImage'] as String? ?? 
                     json['bannerImageUrl'] as String? ?? 
                     json['imageUrl'] as String? ?? 
                     'assets/images/Events/artist-2 1 (2).png';
    
    // Determine color theme (default to purple)
    EventColor colorTheme = EventColor.purple;
    if (json['colorTheme'] != null) {
      colorTheme = EventColor.values.firstWhere(
        (e) => e.name == json['colorTheme'],
        orElse: () => EventColor.purple,
      );
    } else if (json['category'] != null) {
      // Map category to color if available
      final category = json['category'] as String;
      switch (category.toLowerCase()) {
        // Purple - Learning and Achievement
        case 'competition':
        case 'workshop':
          colorTheme = EventColor.purple;
          break;
        // Cyan - Community and Nature
        case 'community':
        case 'environment':
        case 'meeting':
          colorTheme = EventColor.cyan;
          break;
        // Red - Action and Energy
        case 'fundraiser':
        case 'sports':
        case 'social':
          colorTheme = EventColor.red;
          break;
        // Black - Default/Neutral
        case 'general':
        default:
          colorTheme = EventColor.black;
          break;
      }
    }
    
    return Event(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Untitled Event',
      eventName: eventName,
      organizer: organizer,
      date: date,
      month: month,
      imageUrl: imageUrl,
      bannerImageUrl: json['bannerImage'] ?? json['bannerImageUrl'],
      description: json['description'] as String?,
      isJoined: isJoined,
      colorTheme: colorTheme,
      eventDate: parsedEventDate,
      location: json['location'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'eventName': eventName,
      'organizer': organizer,
      'date': date,
      'month': month,
      'imageUrl': imageUrl,
      'bannerImageUrl': bannerImageUrl,
      'description': description,
      'isJoined': isJoined,
      'colorTheme': colorTheme.name,
      'location': location,
      'category': category,
    };
  }
}

enum EventColor {
  purple,
  black,
  cyan,
  red,
}
