import '../models/event.dart';

class EventRepository {
  // Simulated API - replace with actual backend calls
  Future<List<Event>> getAllEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Event(
        id: '1',
        title: 'AlgoArena',
        eventName: 'Mobile App Development\nCompetition',
        organizer: 'Leo Club of\nUniversity of Sri Jayewardenepura',
        date: '23',
        month: 'Nov',
        imageUrl: 'assets/images/Events/artist-2 1 (2).png',
        bannerImageUrl: 'assets/images/Event_interior/Rectangle 2359.png',
        description: '''

Step into the core of modern computing as we uncover,

"𝐔𝐈/𝐔𝐗 & 𝐌𝐨𝐛𝐢𝐥𝐞 𝐀𝐩𝐩 𝐃𝐞𝐬𝐢𝐠𝐧 𝐁𝐞𝐬𝐭 𝐏𝐫𝐚𝐜𝐭𝐢𝐜𝐞𝐬"

Learn how systems connect and communicate. 
Explore the backbone of modern applications. 

Unlock the knowledge that transforms skills into impactful digital solutions.

Get ready - updates are on the way.

𝐏𝐚𝐫𝐭𝐢𝐜𝐢𝐩𝐚𝐧𝐭𝐬 𝐰𝐡𝐨 𝐣𝐨𝐢𝐧 𝐚𝐥𝐥 𝐟𝐨𝐮𝐫 𝐰𝐨𝐫𝐤𝐬𝐡𝐨𝐩𝐬 𝐰𝐢𝐥𝐥 𝐛𝐞 𝐚𝐰𝐚𝐫𝐝𝐞𝐝 𝐚𝐧 𝐨𝐟𝐟𝐢𝐜𝐢𝐚𝐥 𝐞-𝐜𝐞𝐫𝐭𝐢𝐟𝐢𝐜𝐚𝐭𝐞.

Join us on WhatsApp:
https://shorturl.at/26WuT

Flyer Designed by: Prospect  Sujani Nawoda
Caption written by: Prospect Sahani Mithara 

FB: https://www.facebook.com/share/p/19qsPHE51a/?mibextid=wwXIfr

IG: https://www.instagram.com/p/DPx5dhCE8Vs/?igsh=MTdoeTI4bjk3c3lrMg==

#AlgoArena 
#RiseofAurora
#LeoUSJ 
#LeoDis306D2 
#LeoMD306 
#LionsInternational 
#LeosofSriLankaandMaldives
#IEEEUSJ
#CS
#IEEESB

.''',
        isJoined: true,
        colorTheme: EventColor.purple,
      ),
      Event(
        id: '2',
        title: '𝗟𝗲𝗼 𝗟𝗶𝗻𝗲',
        eventName: 'Blog Article Series',
        organizer: 'Leo Club of\nUniversity of Colombo',
        date: '1',
        month: 'Dec',
        imageUrl: 'assets/images/Events/artist-2 1 (1).png',
        colorTheme: EventColor.black,
      ),
      Event(
        id: '3',
        title: 'Presidents Camp',
        eventName: 'Presidents & Council officers\' Camp',
        organizer: 'Leo District 306 D2',
        date: '7',
        month: 'Dec',
        imageUrl: 'assets/images/Events/artist-2 1 (3).png',
        colorTheme: EventColor.cyan,
      ),
      Event(
        id: '4',
        title: 'Blood Donation',
        eventName: 'Blood Donation Campaign',
        organizer: 'Leo Club of Colombo',
        date: '10',
        month: 'Dec',
        imageUrl: 'assets/images/Events/artist-2 1.png',
        colorTheme: EventColor.red,
      ),
      Event(
        id: '5',
        title: 'Presidents Camp',
        eventName: 'Presidents & Council officers\' Camp',
        organizer: 'Leo District 306 D2',
        date: '15',
        month: 'Dec',
        imageUrl: 'assets/images/Events/artist-2 1 (3).png',
        colorTheme: EventColor.cyan,
      ),
    ];
  }

  Future<Event> getEventById(String id) async {
    final events = await getAllEvents();
    return events.firstWhere(
      (event) => event.id == id,
      orElse: () => throw Exception('Event not found'),
    );
  }

  Future<List<Event>> getJoinedEvents() async {
    final events = await getAllEvents();
    return events.where((event) => event.isJoined).toList();
  }

  Future<Event> toggleJoinEvent(String eventId, bool isJoined) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final event = await getEventById(eventId);
    return event.copyWith(isJoined: isJoined);
  }
}
