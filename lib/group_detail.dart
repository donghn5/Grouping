import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'data/models/group.dart';
import 'data/models/user_profile.dart';
import 'data/repositories/groups_repository.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key, required this.group});
  final Group group;

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  // ----- 데모: 다가오는 일정 -----
  late final List<_GroupEvent> _events;
  late final Map<DateTime, List<_GroupEvent>> _eventsByDay;

  // ----- 달력 상태 -----
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // ----- 데모 사진 에셋 -----
  final List<String> _demoImages = const [
    'assets/demo/pic1.jpg',
    'assets/demo/pic2.jpg',
    'assets/demo/pic3.jpg',
    'assets/demo/pic4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _events = _fakeEvents();
    _eventsByDay = _groupByDay(_events);
    _selectedDay = DateTime.now();
  }

  List<_GroupEvent> _fakeEvents() {
    final now = DateTime.now();
    return [
      _GroupEvent('스터디 모임', now.add(const Duration(days: 1)), '강남 카페'),
      _GroupEvent('사진 촬영',  now.add(const Duration(days: 3)), '한강공원'),
      _GroupEvent('저녁식사',   now.add(const Duration(days: 7)), '홍대'),
      _GroupEvent('등산',       now.add(const Duration(days: 10)), '북한산'),
    ];
  }

  Map<DateTime, List<_GroupEvent>> _groupByDay(List<_GroupEvent> items) {
    Map<DateTime, List<_GroupEvent>> map = {};
    for (final e in items) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  List<_GroupEvent> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventsByDay[key] ?? const [];
  }

  // ----- 데모 친구 목록 (체크해서 그룹에 추가) -----
  List<UserProfile> get _demoFriends => [
        UserProfile(uid: 'demo-001', name: '민수', email: 'minsu@example.com'),
        UserProfile(uid: 'demo-002', name: '윤범', email: 'yb123@example.com'),
        UserProfile(uid: 'demo-003', name: '동현', email: 'test@example.com'),
      ];

  Future<void> _openAddMembersSheet() async {
    // 이미 멤버인 사람은 체크/비활성 처리
    final currentMemberIds = <String>{...widget.group.memberIds};

    final selected = <String>{};
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        bool loading = false;
        return StatefulBuilder(builder: (ctx, setState) {
          final inset = MediaQuery.of(ctx).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('친구 추가',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ..._demoFriends.map((f) {
                  final already = currentMemberIds.contains(f.uid);
                  final checked = selected.contains(f.uid);
                  return CheckboxListTile(
                    value: already ? true : checked,
                    onChanged: already
                        ? null
                        : (v) => setState(() {
                              if (v == true) {
                                selected.add(f.uid);
                              } else {
                                selected.remove(f.uid);
                              }
                            }),
                    title: Text(f.name ?? f.uid),
                    subtitle: Text(f.email ?? ''),
                    controlAffinity: ListTileControlAffinity.leading,
                    secondary:
                        already ? const Text('이미 멤버', style: TextStyle(color: Colors.grey))
                                : null,
                  );
                }).toList(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: loading || selected.isEmpty
                        ? null
                        : () async {
                            setState(() => loading = true);
                            try {
                              await GroupsRepository().addMembers(
                                groupId: widget.group.id,
                                uids: selected.toList(),
                              );
                              if (mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('그룹에 친구를 추가했습니다')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('추가 실패: $e')),
                                );
                              }
                            } finally {
                              setState(() => loading = false);
                            }
                          },
                    child: Text(loading ? '추가 중...' : '추가'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    return Scaffold(
      appBar: AppBar(
        title: Text(g.name),
        actions: [
          IconButton(
            onPressed: _openAddMembersSheet,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: '친구 추가',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 다가오는 일정
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('다가오는 일정'),
                  const SizedBox(height: 8),
                  if (_events.isEmpty)
                    const Text('예정된 일정이 없어요')
                  else
                    ..._events.take(3).map((e) => _EventCard(e)),
                ],
              ),
            ),
          ),

          // 달력
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('달력'),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TableCalendar<_GroupEvent>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (d) =>
                          _selectedDay != null &&
                          d.year == _selectedDay!.year &&
                          d.month == _selectedDay!.month &&
                          d.day == _selectedDay!.day,
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                        });
                      },
                      eventLoader: _getEventsForDay,
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.black12, shape: BoxShape.circle),
                        selectedDecoration: BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._getEventsForDay(_selectedDay ?? DateTime.now())
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _EventChip(e),
                          )),
                ],
              ),
            ),
          ),

          // 사진첩
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('사진첩'),
                  const SizedBox(height: 8),
                  GridView.builder(
                    itemCount: _demoImages.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(_demoImages[i], fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupEvent {
  final String title;
  final DateTime date;
  final String? place;
  _GroupEvent(this.title, this.date, this.place);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      );
}

class _EventCard extends StatelessWidget {
  const _EventCard(this.e);
  final _GroupEvent e;
  @override
  Widget build(BuildContext context) {
    final d = e.date;
    final when =
        '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} '
        '(${['일','월','화','수','목','금','토'][d.weekday % 7]}) '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.event_rounded),
        title: Text(e.title),
        subtitle: Text('${e.place ?? ''}  •  $when'),
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip(this.e);
  final _GroupEvent e;
  @override
  Widget build(BuildContext context) {
    final d = e.date;
    final when = '${d.month}/${d.day} ${d.hour}:${d.minute.toString().padLeft(2,'0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8),
          const SizedBox(width: 8),
          Expanded(child: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text(when, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
