import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/repositories/groups_repository.dart';
import 'data/repositories/friends_repository.dart';
import 'data/models/group.dart';
import 'data/models/user_profile.dart';
import 'services/auth_service.dart';
import 'group_detail.dart';

// 데모 앨범(에셋) — pubspec.yaml에 assets/demo/ 등록되어 있어야 함
const List<String> kDemoAlbumAssets = [
  'assets/demo/pic1.jpg',
  'assets/demo/pic2.jpg',
  'assets/demo/pic3.jpg',
  'assets/demo/pic4.jpg',
  // 원하면 더 추가
];

/// 홈의 "Grouping" 로고 자리와 동일한 여백/위치의 간단 타이틀(기본 폰트)
class _PlainTopTitle extends StatelessWidget {
  const _PlainTopTitle(this.text, {this.trailing, super.key});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 24, // 홈의 pacifico 34와 동일 크기
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _GroupsGridLive(),
      const _FriendsLiveScreen(),
      const _AllAlbumsScreen(),
      const _MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: pages),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BlurBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

/// 상단 대제목(Pacifico) + 2열 컬러 타일  ← 검색바 제거됨
class _HomeShortcutsStyleGrid extends StatelessWidget {
  const _HomeShortcutsStyleGrid({required this.groups});
  final List<Group> groups; // Group 그대로 사용

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    // 단축어 앱 느낌의 팔레트/아이콘 (⬇️ 빌드 내부에 둠)
    final gradients = <LinearGradient>[
      const LinearGradient(colors: [Color(0xFF5B8CFF), Color(0xFF3E6BFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFFC9B09A), Color(0xFFA98A70)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF5161F5), Color(0xFF7C8BFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF2BC8A3), Color(0xFF35D07F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFFDB72E4), Color(0xFFF0A6FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFFA67CFF), Color(0xFFC4A1FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFFFF7EB3), Color(0xFFFFB5D8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ];
    final icons = <IconData>[
      Icons.developer_board, Icons.auto_awesome_motion_rounded,
      Icons.vpn_lock_rounded, Icons.power_settings_new_rounded,
      Icons.language_rounded, Icons.menu_book_rounded,
      Icons.travel_explore_rounded, Icons.science_rounded,
    ];

    return CustomScrollView(
      slivers: [
        // 헤더 (Pacifico "Grouping" + + 버튼)
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Grouping',
                      style: GoogleFonts.pacifico(
                        fontSize: 34, height: 1.1, color: Colors.black,
                      )),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _openCreateGroupSheet(context),
                    icon: const Icon(Icons.add, size: 28),
                    tooltip: '새 그룹',
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2열 타일
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + padding.bottom + 80),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final g = groups[index];
              final grad = gradients[index % gradients.length];
              final icon = icons[index % icons.length];

              return _ShortcutTile(
                title: g.name,
                gradient: grad,
                leadingIcon: icon,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => GroupDetailPage(group: g)),
                  );
                },
                onMore: () => _showGroupActions(context, g),
              );
            }, childCount: groups.length),
          ),
        ),
      ],
    );
  }

  // ----- 메뉴: 삭제/나가기 -----
  Future<void> _showGroupActions(BuildContext context, Group g) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final isOwner = g.ownerId == uid;

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(isOwner ? '소유자' : '멤버'),
              ),
              const Divider(height: 1),
              if (isOwner)
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('그룹 삭제', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final ok = await _confirm(context,
                      title: '그룹 삭제',
                      message: '정말 “${g.name}” 그룹을 삭제할까요?\n(모든 멤버에게서 사라집니다)');
                    if (ok == true) {
                      try {
                        await GroupsRepository().deleteGroup(g.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('그룹이 삭제되었습니다')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('삭제 실패: $e')),
                          );
                        }
                      }
                    }
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: const Text('그룹 나가기', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final ok = await _confirm(context,
                      title: '그룹 나가기',
                      message: '“${g.name}” 그룹에서 나갈까요?');
                    if (ok == true) {
                      try {
                        await GroupsRepository().leaveGroup(groupId: g.id, uid: uid);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('그룹을 나갔습니다')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('나가기 실패: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _confirm(BuildContext context, {required String title, required String message}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('확인')),
        ],
      ),
    );
  }

  // ----- 새 그룹 생성 시트 -----
  Future<void> _openCreateGroupSheet(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final nameCtrl = TextEditingController();
    final palette = <Color>[
      const Color(0xFF5B8CFF), const Color(0xFFFF6B6B), const Color(0xFF2BC8A3),
      const Color(0xFF7C8BFF), const Color(0xFFFF7EB3), const Color(0xFFA67CFF),
      const Color(0xFFC9B09A), const Color(0xFF35D07F),
    ];
    Color? picked;

    String _hex(Color c) =>
        '#${c.red.toRadixString(16).padLeft(2, '0')}${c.green.toRadixString(16).padLeft(2, '0')}${c.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

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
          final inset = MediaQuery.of(ctx).viewInsets.bottom; // if error, use MediaQuery
          // correction: use MediaQuery
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('새 그룹 만들기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: '그룹 이름',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onSubmitted: (_) => FocusScope.of(ctx).unfocus(),
                ),
                const SizedBox(height: 12),
                const Text('색상 (선택)', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    for (final c in palette)
                      GestureDetector(
                        onTap: () => setState(() => picked = c),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: picked == c ? Colors.black : Colors.black12,
                              width: picked == c ? 2 : 1,
                            ),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () => setState(() => picked = null),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: FilledButton(
                    onPressed: loading ? null : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이름을 입력해주세요')));
                        return;
                      }
                      setState(() => loading = true);
                      try {
                        await GroupsRepository().createGroup(
                          name: name, ownerId: uid,
                          colorHex: picked == null ? null : _hex(picked!),
                        );
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('그룹 "$name"이 생성되었습니다')));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('생성 실패: $e')));
                        }
                      } finally {
                        setState(() => loading = false);
                      }
                    },
                    child: Text(loading ? '생성 중...' : '생성'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}


class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.title,
    required this.gradient,
    required this.leadingIcon,
    this.onTap,
    this.onMore,
  });

  final String title;
  final LinearGradient gradient;
  final IconData leadingIcon;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                Positioned(
                  top: 4,
                  left: 4,
                  child: Icon(leadingIcon,
                      size: 28, color: Colors.white.withOpacity(0.95)),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onMore,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.more_horiz_rounded,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 2),
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(blurRadius: 0.5, color: Colors.black26)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 하단 블러 네비 동일
class _BlurBottomNavBar extends StatelessWidget {
  const _BlurBottomNavBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.only(bottom: bottom > 0 ? bottom : 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.40),
                Colors.white.withOpacity(0.75),
                Colors.white.withOpacity(0.95)
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border:
                Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavIcon(
                      icon: Icons.home_rounded,
                      selected: currentIndex == 0,
                      onTap: () => onTap(0)),
                  _NavIcon(
                      icon: Icons.group_rounded,
                      selected: currentIndex == 1,
                      onTap: () => onTap(1)),
                  _NavIcon(
                      icon: Icons.photo_library_rounded,
                      selected: currentIndex == 2,
                      onTap: () => onTap(2)),
                  _NavIcon(
                      icon: Icons.more_horiz_rounded,
                      selected: currentIndex == 3,
                      onTap: () => onTap(3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon(
      {required this.icon, required this.selected, required this.onTap});
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : Colors.black54;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(icon, size: 26, color: color),
      ),
    );
  }
}

// Firestore 실데이터로 그리드 뿌리기
class _GroupsGridLive extends StatelessWidget {
  const _GroupsGridLive();
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<List<Group>>(
      stream: GroupsRepository().watchMyGroups(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final groups = snap.data ?? const <Group>[];
        // 기존 타일 렌더를 재사용하기 위해 이름 리스트로 변환
        return _HomeShortcutsStyleGrid(groups: groups);
      },
    );
  }
}

// Firestore에서 친구 목록(이름/이메일) 가져오기
class _FriendsLiveScreen extends StatelessWidget {
  const _FriendsLiveScreen();

  // 데모 친구(시연용)
  List<UserProfile> get _demoFriends => [
    UserProfile(uid: 'demo-001', name: '민수',  email: 'minsu@example.com'),
    UserProfile(uid: 'demo-002', name: '지연',  email: 'jiyun@example.com'),
    UserProfile(uid: 'demo-003', name: '테스트', email: 'test@example.com'),
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<UserProfile>>(
      stream: FriendsRepository().watchFriends(uid),
      builder: (context, snap) {
        final fromDb = snap.data ?? const <UserProfile>[];
        final byId = <String, UserProfile>{
          for (final f in _demoFriends) f.uid: f,
          for (final f in fromDb) f.uid: f,
        };
        final friends = byId.values.toList();

        // 상단 헤더 + 리스트(슬리버)
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _PlainTopTitle('친구')),
            if (snap.connectionState == ConnectionState.waiting && friends.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (friends.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('친구가 아직 없어요')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    // 구분선 포함하도록 2n-1 개로 만든다.
                    if (i.isOdd) return const Divider(height: 1);
                    final idx = i ~/ 2;
                    final f = friends[idx];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(f.name ?? f.uid,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(f.email ?? '',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  },
                  childCount: friends.length * 2 - 1,
                ),
              ),
            // 하단 블러바와 겹치지 않도록 여백
            SliverToBoxAdapter(
              child: SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
            ),
          ],
        );
      },
    );
  }
}

class _AllAlbumsScreen extends StatelessWidget {
  const _AllAlbumsScreen();

  void _openViewer(BuildContext context, String asset) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.black,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Image.asset(asset, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _PlainTopTitle('모든 앨범')),
        if (kDemoAlbumAssets.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('표시할 사진이 없어요')),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              12, 0, 12, 12 + MediaQuery.of(context).padding.bottom + 80,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final asset = kDemoAlbumAssets[i];
                  return GestureDetector(
                    onTap: () => _openViewer(context, asset),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(asset, fit: BoxFit.cover),
                    ),
                  );
                },
                childCount: kDemoAlbumAssets.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _PlainTopTitle('더보기')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('로그아웃'),
                onTap: () async {
                  await AuthService.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
                  }
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
        ),
      ],
    );
  }
}


class _CenterTextPage extends StatelessWidget {
  const _CenterTextPage(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
