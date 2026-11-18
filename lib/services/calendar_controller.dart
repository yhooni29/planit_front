import 'package:flutter/foundation.dart';

import '../models/calendar_event.dart';
import 'rooms_controller.dart';

/// Shared by the home and calendar routes for this local login session.
class CalendarController extends ChangeNotifier {
  CalendarController({required this.roomsController}) {
    roomsController.addListener(_roomsChanged);
  }

  final RoomsController roomsController;
  final Map<String, CalendarEvent> _personalEvents = {};
  final Map<EventCategory, int> _categoryColors = {};
  int _nextId = 0;
  String? _ddayEventId;

  String? get ddayEventId => _ddayEventId;

  void setDday(String? eventId) {
    if (eventId != null && !events.any((event) => event.id == eventId)) {
      throw ArgumentError('Choose an existing calendar event.');
    }
    if (_ddayEventId == eventId) return;
    _ddayEventId = eventId;
    notifyListeners();
  }

  List<CalendarEntry> upcomingEntries(DateTime now) {
    final entries = events
        .map((event) => event.nextEntry(now))
        .whereType<CalendarEntry>()
        .toList();
    entries.sort((a, b) => a.start.compareTo(b.start));
    return entries;
  }

  /// One choice per event; repeating events use the next active occurrence.
  List<CalendarEntry> ddayChoices(DateTime now) {
    final entries = events
        .map(
          (event) =>
              event.nextEntry(now) ??
              CalendarEntry(event: event, start: event.start, end: event.end),
        )
        .toList();
    entries.sort((a, b) {
      final aPast = !a.end.isAfter(now);
      final bPast = !b.end.isAfter(now);
      if (aPast != bPast) return aPast ? 1 : -1;
      return aPast ? b.start.compareTo(a.start) : a.start.compareTo(b.start);
    });
    return entries;
  }

  CalendarEntry? featuredEntry(DateTime now) {
    if (_ddayEventId != null) {
      for (final entry in ddayChoices(now)) {
        if (entry.event.id == _ddayEventId) return entry;
      }
    }
    final upcoming = upcomingEntries(now);
    return upcoming.isEmpty ? null : upcoming.first;
  }

  String newEventId() => 'personal-${_nextId++}';

  int colorFor(EventCategory category) =>
      _categoryColors[category] ?? category.colorValue;

  void setCategoryColor(EventCategory category, int colorValue) {
    if (colorFor(category) == colorValue) return;
    _categoryColors[category] = colorValue;
    notifyListeners();
  }

  List<CalendarEvent> get events => [
    ..._personalEvents.values,
    for (final room in roomsController.rooms)
      if (room.date != null)
        CalendarEvent(
          id: 'room-${room.id}',
          roomId: room.id,
          title: room.title,
          start: room.date!,
          // Rooms currently have only a start time; do not invent a duration.
          end: room.date!.add(const Duration(microseconds: 1)),
          category: room.category,
          location: room.region == '지역 미정' ? '' : room.region,
          notes: room.status.label,
        ),
  ];

  List<CalendarEntry> entriesOn(DateTime day) {
    final entries = events.expand((event) => event.entriesOn(day)).toList();
    entries.sort((a, b) {
      if (a.event.allDay != b.event.allDay) return a.event.allDay ? -1 : 1;
      return a.start.compareTo(b.start);
    });
    return entries;
  }

  void save(CalendarEvent event) {
    if (event.roomId != null || event.id.startsWith('room-')) {
      throw ArgumentError('Room events are managed by RoomsController.');
    }
    if (event.title.trim().isEmpty || !event.end.isAfter(event.start)) {
      throw ArgumentError(
        'A title and a positive event duration are required.',
      );
    }
    _personalEvents[event.id] = event;
    notifyListeners();
  }

  void delete(String id) {
    if (_personalEvents.remove(id) != null) {
      if (_ddayEventId == id) _ddayEventId = null;
      notifyListeners();
    }
  }

  void _roomsChanged() {
    if (_ddayEventId != null &&
        !events.any((event) => event.id == _ddayEventId)) {
      _ddayEventId = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    roomsController.removeListener(_roomsChanged);
    super.dispose();
  }
}
