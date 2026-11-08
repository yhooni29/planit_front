
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'create_room_screen.dart';

class PlanRoom {
  final String name;
  final String code;
  final DateTime createdAt;
  final int capacity;

  PlanRoom({
    required this.name,
    required this.code,
    required this.createdAt,
    required this.capacity,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryBlue = Color(0xFF4F7CFF);
  static const Color darkBlue = Color(0xFF142F5F);

  final List<PlanRoom> _rooms = [];



  void _showAddMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  '새로운 약속 시작하기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF0FF),
                    child: Icon(Icons.add_home_outlined,
                        color: primaryBlue),
                  ),
                  title: const Text('방 만들기'),
                  subtitle: const Text('새로운 약속방을 만들어요'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showCreateRoomDialog();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF0FF),
                    child: Icon(Icons.key_outlined,
                        color: primaryBlue),
                  ),
                  title: const Text('코드로 참여하기'),
                  subtitle: const Text('친구에게 받은 초대 코드를 입력해요'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showJoinRoomDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _showCreateRoomDialog() async {
    final result = await Navigator.push<CreatedRoom>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateRoomScreen(),
      ),
    );

    if (!mounted || result == null) return;


    final room = PlanRoom(
      name: result.name,
      code: result.code,
      createdAt: DateTime.now(),
      capacity: result.capacity,
    );


    setState(() {
      _rooms.add(room);
    });

    _showRoomCreatedDialog(room);
  }


  void _showRoomCreatedDialog(PlanRoom room) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('방이 만들어졌어요! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                room.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              const Text('초대 코드'),
              const SizedBox(height: 8),
              SelectableText(
                room.code,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '친구에게 이 코드를 공유해 보세요.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: room.code),
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('코드 복사'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showJoinRoomDialog() async {
    final controller = TextEditingController();

    final inputCode = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('코드로 참여하기'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            maxLength: 7,
            inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z0-9#@!]'),
              ),
            ],
            decoration: const InputDecoration(
              labelText: '초대 코드',
              hintText: '7자리 코드 입력',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim().toUpperCase(),
                );
              },
              child: const Text('참여하기'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || inputCode == null) return;


    if (inputCode.length != 7) {
      _showMessage('초대 코드는 7자리입니다.');
      return;
    }


    // 아직 서버가 없으므로 다른 사용자의 방은 조회할 수 없음.
    final existingRoom = _rooms.where(
          (room) => room.code == inputCode,
    );

    if (existingRoom.isNotEmpty) {
      _showMessage('이미 내 목록에 있는 방이에요.');
    } else {
      _showMessage(
        '코드 입력 완료! 실제 방 참여는 서버 연결 후 가능해요.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openRoom(PlanRoom room) {
    // TODO: 추후 방 상세 화면 연결
    _showMessage('${room.name}의 상세 화면은 다음 단계에서 만들어요.');
  }

  Widget _buildRoomCard(PlanRoom room, int index) {
    const colors = [
      Color(0xFFEAF0FF),
      Color(0xFFE6F7F4),
      Color(0xFFFFF1E5),
      Color(0xFFF3EAFF),
    ];

    final color = colors[index % colors.length];

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openRoom(room),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: primaryBlue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      '정원 ${room.capacity}명 · 초대 코드: ${room.code}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                  ],
                ),
              ),
              IconButton(
                tooltip: '초대 코드 복사',
                icon: const Icon(
                  Icons.copy_outlined,
                  color: Colors.grey,
                ),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: room.code),
                  );
                  if (mounted) {
                    _showMessage('초대 코드가 복사됐어요.');
                  }
                },
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF0FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 48,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '아직 참여한 방이 없어요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '새로운 방을 만들거나\n친구에게 받은 코드로 참여해 보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _showAddMenu,
              icon: const Icon(Icons.add),
              label: const Text('약속방 시작하기'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'PlanIt',
          style: TextStyle(
            color: primaryBlue,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: '프로필',
            onPressed: () {
              _showMessage('프로필 화면은 추후 연결할 예정이에요.');
            },
            icon: const Icon(
              Icons.account_circle_outlined,
              size: 29,
              color: darkBlue,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '함께 만드는 더 좋은 하루, 플랜잇',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '내 약속방',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  Text(
                    '${_rooms.length}개의 방',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _rooms.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    return _buildRoomCard(
                      _rooms[index],
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
