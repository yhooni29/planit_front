import 'package:flutter/material.dart';

import '../../models/calendar_event.dart';
import '../../services/calendar_controller.dart';
import '../../widgets/planit_mascot.dart';
import '../profile/profile_widgets.dart';
import 'event_editor_sheet.dart';
import 'calendar_colors_sheet.dart';

const _ink = profileInk;
const _muted = Color(0xFF6C879A);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    required this.controller,
    this.onOpenRoom,
    this.initialDate,
    this.today,
  });

  final CalendarController controller;
  final ValueChanged<String>? onOpenRoom;
  final DateTime? initialDate;
  final DateTime? today;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selected;
  late DateTime _month;
  bool _mondayFirst = false;
  bool _colorWeekends = false;

  DateTime get _today => calendarDay(widget.today ?? DateTime.now());

  @override
  void initState() {
    super.initState();
    _selected = calendarDay(widget.initialDate ?? _today);
    _month = DateTime(_selected.year, _selected.month);
  }

  void _select(DateTime day) => setState(() {
    _selected = calendarDay(day);
    _month = DateTime(day.year, day.month);
  });

  void _changeMonth(int offset) {
    final month = DateTime(_month.year, _month.month + offset);
    if (month.year < 1900 || month.year > 2200) return;
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    _select(
      DateTime(
        month.year,
        month.month,
        _selected.day > lastDay ? lastDay : _selected.day,
      ),
    );
  }

  Future<void> _jumpToDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200, 12, 31),
      helpText: '이동할 날짜',
      builder: (context, child) =>
          Theme(data: profileTheme(context), child: child!),
    );
    if (date != null && mounted) _select(date);
  }

  Future<void> _search() async {
    final event = await showSearch<CalendarEvent?>(
      context: context,
      delegate: _EventSearch(widget.controller),
    );
    if (event != null && mounted) _select(event.start);
  }

  void _edit([CalendarEvent? event]) {
    if (event?.roomId != null) {
      widget.onOpenRoom?.call(event!.roomId!);
      return;
    }
    showEventEditor(
      context,
      controller: widget.controller,
      date: _selected,
      event: event,
    );
  }

  List<DateTime> get _days {
    final offset = _mondayFirst ? _month.weekday - 1 : _month.weekday % 7;
    final count = DateTime(_month.year, _month.month + 1, 0).day;
    final total = ((offset + count) / 7).ceil() * 7;
    return List.generate(
      total,
      (i) => DateTime(_month.year, _month.month, 1 - offset + i),
    );
  }

  void _showMonthAgenda() {
    final monthDays = DateTime(_month.year, _month.month + 1, 0).day;
    final entries = <({DateTime day, CalendarEntry entry})>[
      for (var d = 1; d <= monthDays; d++)
        for (final entry in widget.controller.entriesOn(
          DateTime(_month.year, _month.month, d),
        ))
          (day: DateTime(_month.year, _month.month, d), entry: entry),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: profileSurface,
      builder: (sheetContext) => Theme(
        data: profileTheme(sheetContext),
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .65,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${_month.year}년 ${_month.month}월 일정 목록',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(child: Text('이번 달에 등록된 일정이 없어요.'))
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (_, index) {
                            final item = entries[index];
                            return ListTile(
                              leading: Text(
                                '${item.day.day}',
                                style: const TextStyle(fontSize: 23),
                              ),
                              title: Text(item.entry.event.title),
                              subtitle: Text(
                                '${item.entry.event.category.label} · ${item.entry.event.allDay ? '하루종일' : calendarTimeLabel(item.entry.start)}',
                              ),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                _select(item.day);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: profileTheme(context),
    child: Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: profileSurface,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFFB9E4F8), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1629ACF0),
                  blurRadius: 32,
                  spreadRadius: 3,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) => LayoutBuilder(
                builder: (context, constraints) {
                  final days = _days;
                  final weeks = days.length ~/ 7;
                  final cellHeight = (constraints.maxHeight * .48 / weeks)
                      .clamp(56.0, 84.0);
                  final selectedEntries = widget.controller.entriesOn(
                    _selected,
                  );
                  return Column(
                    children: [
                      _header(),
                      _monthNavigation(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFFE1EDF5),
                                  ),
                                ),
                                child: GestureDetector(
                                  onHorizontalDragEnd: (details) {
                                    final speed = details.primaryVelocity ?? 0;
                                    if (speed.abs() > 150) {
                                      _changeMonth(speed < 0 ? 1 : -1);
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          for (final weekday
                                              in _mondayFirst
                                                  ? [
                                                      '월',
                                                      '화',
                                                      '수',
                                                      '목',
                                                      '금',
                                                      '토',
                                                      '일',
                                                    ]
                                                  : [
                                                      '일',
                                                      '월',
                                                      '화',
                                                      '수',
                                                      '목',
                                                      '금',
                                                      '토',
                                                    ])
                                            Expanded(
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 10,
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    weekday,
                                                    style: const TextStyle(
                                                      color: _muted,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      for (var week = 0; week < weeks; week++)
                                        SizedBox(
                                          height: cellHeight,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              for (var d = 0; d < 7; d++)
                                                Expanded(
                                                  child: _dayCell(
                                                    days[week * 7 + d],
                                                    cellHeight,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  24,
                                  16,
                                  12,
                                ),
                                child: Text(
                                  '${_selected.year}년 ${calendarDateLabel(_selected)}',
                                  key: const ValueKey('selected-date'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _ink,
                                  ),
                                ),
                              ),
                              if (selectedEntries.isEmpty)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    12,
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: profileWell,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '등록된 일정이 없어요.',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              else
                                for (final entry in selectedEntries)
                                  _agendaTile(entry),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                key: const ValueKey('add-calendar-event'),
                                onPressed: () => _edit(),
                                style: TextButton.styleFrom(
                                  backgroundColor: profileBlue,
                                  foregroundColor: Colors.white,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                icon: const Icon(Icons.add, size: 24),
                                label: const Text(
                                  '새로운 이벤트',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              tooltip: '월간 일정 목록',
                              onPressed: _showMonthAgenda,
                              style: IconButton.styleFrom(
                                backgroundColor: profileButton,
                                foregroundColor: _ink,
                                padding: const EdgeInsets.all(18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const Icon(
                                Icons.article_outlined,
                                size: 23,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
    child: Row(
      children: [
        IconButton(
          tooltip: '홈으로 돌아가기',
          onPressed: Navigator.of(context).canPop()
              ? () => Navigator.of(context).pop()
              : null,
          icon: const Icon(Icons.arrow_back_ios_new, size: 19, color: _ink),
          constraints: const BoxConstraints.tightFor(width: 36, height: 44),
          padding: EdgeInsets.zero,
        ),
        const Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Plan',
                        style: TextStyle(color: _ink),
                      ),
                      TextSpan(
                        text: 'it',
                        style: TextStyle(color: profileBlue),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(width: 6),
                PlanitMascot(size: 32),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: '일정 검색',
          onPressed: _search,
          icon: const Icon(Icons.search_rounded, color: _ink, size: 23),
          constraints: const BoxConstraints.tightFor(width: 36, height: 44),
          padding: EdgeInsets.zero,
        ),
        PopupMenuButton<String>(
          tooltip: '달력 설정',
          icon: const Icon(Icons.tune_rounded, color: _ink, size: 22),
          constraints: const BoxConstraints(minWidth: 180),
          padding: EdgeInsets.zero,
          onSelected: (value) {
            if (value == 'colors') {
              showCalendarColors(context, widget.controller);
              return;
            }
            setState(() {
              if (value == 'monday') _mondayFirst = !_mondayFirst;
              if (value == 'weekend') _colorWeekends = !_colorWeekends;
            });
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'colors', child: Text('분류별 색상')),
            CheckedPopupMenuItem(
              value: 'monday',
              checked: _mondayFirst,
              child: const Text('월요일부터 시작'),
            ),
            CheckedPopupMenuItem(
              value: 'weekend',
              checked: _colorWeekends,
              child: const Text('주말 색상 표시'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _monthNavigation() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 2, 12, 12),
    child: Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _jumpToDate,
            style: TextButton.styleFrom(
              foregroundColor: _ink,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.centerLeft,
            ),
            child: Tooltip(
              message: '날짜 이동',
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_month.year}년 ${_month.month}월',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.expand_more_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => _select(_today),
          style: TextButton.styleFrom(
            foregroundColor: profileBlue,
            backgroundColor: profileButton,
            minimumSize: const Size(58, 32),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shape: const StadiumBorder(),
          ),
          child: const Text(
            'TODAY',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 4),
        for (final offset in [-1, 1])
          IconButton(
            tooltip: offset < 0 ? '이전 달' : '다음 달',
            onPressed: () => _changeMonth(offset),
            icon: Icon(
              offset < 0
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
            ),
            color: profileBlue,
            constraints: const BoxConstraints.tightFor(width: 32, height: 40),
            padding: EdgeInsets.zero,
          ),
      ],
    ),
  );

  Widget _dayCell(DateTime day, double height) {
    final entries = widget.controller.entriesOn(day);
    final selected = day == _selected;
    final currentMonth = day.month == _month.month && day.year == _month.year;
    final slots = ((height - 30) / 15).floor().clamp(1, 3);
    final visibleCount = entries.length > slots ? slots - 1 : entries.length;
    final weekend = day.weekday == 7
        ? const Color(0xFFC87878)
        : const Color(0xFF7092BF);
    return Semantics(
      button: true,
      selected: selected,
      label: '${day.year}년 ${calendarDateLabel(day)}, 일정 ${entries.length}개',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
        child: Material(
          color: selected
              ? profileBlue
              : day == _today
              ? profileButton
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('calendar-day-${day.year}-${day.month}-${day.day}'),
            onTap: () => _select(day),
            onLongPress: () {
              _select(day);
              _edit();
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : !currentMonth
                          ? const Color(0xFFAFC2CF)
                          : _colorWeekends && day.weekday >= 6
                          ? weekend
                          : _ink,
                    ),
                  ),
                ),
                for (var i = 0; i < visibleCount; i++)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: Color(
                        widget.controller.colorFor(entries[i].event.category),
                      ).withValues(alpha: selected ? .3 : .13),
                      border: Border(
                        left: BorderSide(
                          color: Color(
                            widget.controller.colorFor(
                              entries[i].event.category,
                            ),
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      entries[i].event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.25,
                        color: selected ? Colors.white : _ink,
                      ),
                    ),
                  ),
                if (entries.length > visibleCount)
                  Text(
                    '+${entries.length - visibleCount}개',
                    style: TextStyle(
                      fontSize: 9,
                      color: selected ? Colors.white70 : _muted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _agendaTile(CalendarEntry entry) {
    final event = entry.event;
    final color = Color(widget.controller.colorFor(event.category));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE1EDF5)),
        ),
        child: ListTile(
          key: ValueKey('agenda-${event.id}-${entry.start.toIso8601String()}'),
          onTap: () => _edit(event),
          leading: Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          minLeadingWidth: 4,
          title: Text(
            event.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${_entryTimeLabel(entry)} · ${event.category.label}${event.location.isEmpty ? '' : ' · ${event.location}'}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Icon(
            event.roomId == null
                ? Icons.chevron_right
                : Icons.meeting_room_outlined,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }

  String _entryTimeLabel(CalendarEntry entry) {
    if (entry.event.allDay) return '하루종일';
    if (entry.event.roomId != null) return calendarTimeLabel(entry.start);
    if (entry.end.hour == 0 &&
        entry.end.minute == 0 &&
        calendarDay(entry.end) ==
            DateTime(
              entry.start.year,
              entry.start.month,
              entry.start.day + 1,
            )) {
      return '${calendarTimeLabel(entry.start)} – 24:00';
    }
    if (calendarDay(entry.start) == calendarDay(entry.end)) {
      return '${calendarTimeLabel(entry.start)} – ${calendarTimeLabel(entry.end)}';
    }
    return '${entry.start.month}/${entry.start.day} ${calendarTimeLabel(entry.start)} – '
        '${entry.end.month}/${entry.end.day} ${calendarTimeLabel(entry.end)}';
  }
}

class _EventSearch extends SearchDelegate<CalendarEvent?> {
  _EventSearch(this.controller) : super(searchFieldLabel: '일정 검색');
  final CalendarController controller;

  @override
  ThemeData appBarTheme(BuildContext context) => profileTheme(context);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      tooltip: '검색어 지우기',
      onPressed: () => query = '',
      icon: const Icon(Icons.clear),
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    tooltip: '검색 닫기',
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final search = query.trim().toLowerCase();
      final events =
          controller.events
              .where(
                (event) => '${event.title} ${event.location} ${event.notes}'
                    .toLowerCase()
                    .contains(search),
              )
              .toList()
            ..sort((a, b) => a.start.compareTo(b.start));
      if (events.isEmpty) return const Center(child: Text('검색된 일정이 없어요.'));
      return ListView.builder(
        itemCount: events.length,
        itemBuilder: (_, index) {
          final event = events[index];
          return ListTile(
            leading: Icon(
              Icons.circle,
              size: 10,
              color: Color(controller.colorFor(event.category)),
            ),
            title: Text(event.title),
            subtitle: Text(
              '${event.start.year}년 ${calendarDateLabel(event.start)} · ${event.category.label}',
            ),
            onTap: () => close(context, event),
          );
        },
      );
    },
  );
}
