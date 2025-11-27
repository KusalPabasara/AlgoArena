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
  });

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
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      eventName: json['eventName'] as String,
      organizer: json['organizer'] as String,
      date: json['date'] as String,
      month: json['month'] as String,
      imageUrl: json['imageUrl'] as String,
      bannerImageUrl: json['bannerImageUrl'] as String?,
      description: json['description'] as String?,
      isJoined: json['isJoined'] as bool? ?? false,
      colorTheme: EventColor.values.firstWhere(
        (e) => e.name == json['colorTheme'],
        orElse: () => EventColor.purple,
      ),
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
    };
  }
}

enum EventColor {
  purple,
  black,
  cyan,
  red,
}
