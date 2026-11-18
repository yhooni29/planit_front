import 'dart:math';

import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../widgets/planit_mascot.dart';
import '../widgets/scroll_time_picker.dart';
import 'profile/profile_widgets.dart';

class CreatedRoom {
  final String name;
  final int capacity;
  final String code;
  final DateTime date;
  final EventCategory category;

  const CreatedRoom({
    required this.name,
    this.capacity = 8,
    required this.code,
    required this.date,
    this.category = EventCategory.personal,
  });
}

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key, this.onJoin});

  final VoidCallback? onJoin;

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  DateTime? _date;
  int? _time;
  EventCategory _category = EventCategory.personal;
  bool _showScheduleError = false;

  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _generateCode() {
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '#@!';
    const all = '$letters$numbers$symbols';

    final random = Random.secure();

    final chars = <String>[
      letters[random.nextInt(letters.length)],
      numbers[random.nextInt(numbers.length)],
      symbols[random.nextInt(symbols.length)],
      ...List.generate(4, (_) => all[random.nextInt(all.length)]),
    ];

    chars.shuffle(random);
    return chars.join();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200, 12, 31),
      helpText: '약속 날짜',
      confirmText: '선택',
      cancelText: '취소',
      builder: (context, child) =>
          Theme(data: profileTheme(context), child: child!),
    );
    if (date == null || !mounted) return;
    setState(() => _date = date);
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final time = await showScrollTimePicker(
      context,
      initialMinutes: _time ?? 13 * 60,
      title: '약속 시간',
    );
    if (time == null || !mounted) return;
    setState(() => _time = time);
  }

  void _createRoom() {
    if (_date == null || _time == null) {
      setState(() => _showScheduleError = true);
      return;
    }
    final name = _nameController.text.trim();

    final room = CreatedRoom(
      name: name.isEmpty ? '새 약속방' : name,
      date: scrollTimeOnDate(_date!, _time!),
      category: _category,
      code: _generateCode(),
    );

    Navigator.pop(context, room);
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
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: const Color(0xFFCAE8F7), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1429ACF0),
                  blurRadius: 28,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: '닫기',
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: profileInk,
                          fixedSize: const Size.square(48),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 26),
                      ),
                      const Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PlanitMascot(size: 30),
                            SizedBox(width: 10),
                            Text(
                              '새 방',
                              style: TextStyle(
                                color: profileInk,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: '방 생성 완료',
                        onPressed: _createRoom,
                        style: IconButton.styleFrom(
                          backgroundColor: profileButton,
                          foregroundColor: profileBlue,
                          fixedSize: const Size.square(48),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 28),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nameController,
                          maxLength: 30,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: profileInk,
                          ),
                          decoration: InputDecoration(
                            labelText: '방 이름 (선택)',
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            counterText: '',
                            labelStyle: const TextStyle(
                              color: Color(0xFF8397A5),
                              fontSize: 16,
                            ),
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color(0xFF9CD6F4),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '분류',
                          style: TextStyle(
                            color: profileInk,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final category in EventCategory.selectable)
                              ChoiceChip(
                                key: ValueKey('room-category-${category.name}'),
                                label: Text(category.label),
                                selected: _category == category,
                                onSelected: (_) =>
                                    setState(() => _category = category),
                                selectedColor: profileButton,
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: _category == category
                                      ? profileBlue
                                      : const Color(0xFFD5E6EF),
                                ),
                                labelStyle: const TextStyle(color: profileInk),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '날짜 및 시간',
                          style: TextStyle(
                            color: profileInk,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _ScheduleField(
                          key: const ValueKey('room-date'),
                          icon: Icons.calendar_month_outlined,
                          label: _date == null
                              ? '날짜 선택'
                              : '${_date!.year}년 ${_date!.month}월 ${_date!.day}일',
                          selected: _date != null,
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 10),
                        _ScheduleField(
                          key: const ValueKey('room-time'),
                          icon: Icons.schedule_rounded,
                          label: _time == null
                              ? '시간 선택'
                              : scrollTimeLabel(_time!),
                          selected: _time != null,
                          onTap: _pickTime,
                        ),
                        const SizedBox(height: 12),
                        if (_showScheduleError &&
                            (_date == null || _time == null))
                          Text(
                            '날짜와 시간을 선택해 주세요.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          )
                        else
                          const Text(
                            '선택한 일정은 캘린더에 표시돼요.',
                            style: TextStyle(
                              color: Color(0xFF6C879A),
                              fontSize: 12,
                            ),
                          ),
                        if (widget.onJoin != null) ...[
                          const SizedBox(height: 26),
                          const Divider(color: Color(0xFFDDEAF2), height: 1),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                              widget.onJoin!();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: profileBlue,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text(
                              '또는 코드 참가',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ScheduleField extends StatelessWidget {
  const _ScheduleField({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(
        color: selected ? const Color(0xFFB9E4F8) : const Color(0xFFE3EDF4),
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: profileBlue, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? profileInk : const Color(0xFF8397A5),
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: profileBlue,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}
