import 'package:flutter/material.dart';
import 'room_widgets.dart';

class RoomPreferenceEditor extends StatefulWidget {
  const RoomPreferenceEditor({
    super.key,
    required this.initialText,
    required this.onSave,
    this.readOnly = false,
  });

  final String initialText;
  final ValueChanged<String> onSave;
  final bool readOnly;

  @override
  State<RoomPreferenceEditor> createState() => _RoomPreferenceEditorState();
}

class _RoomPreferenceEditorState extends State<RoomPreferenceEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant RoomPreferenceEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText &&
        _text.text == oldWidget.initialText) {
      _text.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    if (widget.readOnly || !_formKey.currentState!.validate()) return;
    final value = _text.text.trim();
    widget.onSave(value);
    _text.text = value;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('취향을 저장했어요.')));
  }

  @override
  Widget build(BuildContext context) => RoomPanel(
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '우리의 취향',
                  style: TextStyle(
                    color: roomInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!widget.readOnly)
                TextButton(
                  key: const ValueKey('save-room-preference'),
                  onPressed: _save,
                  style: TextButton.styleFrom(
                    foregroundColor: roomBlue,
                    minimumSize: const Size(48, 48),
                  ),
                  child: const Text('저장'),
                )
              else
                const Tooltip(
                  message: '확정된 약속의 취향',
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: roomMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: const ValueKey('room-preference'),
            controller: _text,
            readOnly: widget.readOnly,
            minLines: 4,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            validator: (value) => value == null || value.trim().isEmpty
                ? '하고 싶은 일을 적어 주세요.'
                : null,
            style: const TextStyle(color: roomInk, fontSize: 14, height: 1.6),
            decoration: InputDecoration(
              hintText: '당일에 하고 싶은 일을 적어 주세요',
              hintStyle: const TextStyle(color: roomMuted, fontSize: 13),
              fillColor: roomBackground,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFDDEAF2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFDDEAF2)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
