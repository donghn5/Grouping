import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/repositories/groups_repository.dart';
import 'data/repositories/friends_repository.dart';
import 'data/models/group.dart';
import 'data/models/user_profile.dart';

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
  final List<String> groups;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    final gradients = <LinearGradient>[
      const LinearGradient(
          colors: [Color(0xFF5B8CFF), Color(0xFF3E6BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFFC9B09A), Color(0xFFA98A70)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFF5161F5), Color(0xFF7C8BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFF2BC8A3), Color(0xFF35D07F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFFDB72E4), Color(0xFFF0A6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFFA67CFF), Color(0xFFC4A1FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFFFF7EB3), Color(0xFFFFB5D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
    ];

    final icons = <IconData>[
      Icons.developer_board,
      Icons.auto_awesome_motion_rounded,
      Icons.vpn_lock_rounded,
      Icons.power_settings_new_rounded,
      Icons.language_rounded,
      Icons.menu_book_rounded,
      Icons.travel_explore_rounded,
      Icons.science_rounded,
    ];

    return CustomScrollView(
      slivers: [
        // 상단 헤더 (Pacifico "Grouping" + + 버튼)
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Grouping',
                    style: GoogleFonts.pacifico(
                      fontSize: 34, // ↓ 42 → 34 로 축소
                      height: 1.1,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: 새 그룹 만들기
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('새 그룹 만들기')),
                      );
                    },
                    icon: const Icon(Icons.add, size: 28),
                    color: Colors.black,
                    tooltip: '새 그룹',
                  ),
                ],
              ),
            ),
          ),
        ),

        // 🔻 검색바 블록 완전 제거됨

        // 2열 타일 그리드
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + padding.bottom + 80),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final name = groups[index];
              final grad = gradients[index % gradients.length];
              final icon = icons[index % icons.length];

              return _ShortcutTile(
                title: name,
                gradient: grad,
                leadingIcon: icon,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Open $name')),
                  );
                },
                onMore: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('More: $name')),
                  );
                },
              );
            }, childCount: groups.length),
          ),
        ),
      ],
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
        return _HomeShortcutsStyleGrid(groups: groups.map((g) => g.name).toList());
      },
    );
  }
}

// Firestore에서 친구 목록(이름/이메일) 가져오기
class _FriendsLiveScreen extends StatelessWidget {
  const _FriendsLiveScreen();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return SafeArea(
      child: StreamBuilder<List<UserProfile>>(
        stream: FriendsRepository().watchFriends(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final friends = snap.data ?? const <UserProfile>[];
          if (friends.isEmpty) {
            return const Center(child: Text('친구가 아직 없어요'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemBuilder: (_, i) {
              final f = friends[i];
              return ListTile(
                leading: CircleAvatar(
                  child: f.photoUrl == null
                      ? const Icon(Icons.person)
                      : ClipOval(child: Image.network(f.photoUrl!, fit: BoxFit.cover)),
                ),
                title: Text(f.name ?? f.uid, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(f.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {}, // TODO: 프로필/DM 등
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: friends.length,
          );
        },
      ),
    );
  }
}

class _AllAlbumsScreen extends StatelessWidget {
  const _AllAlbumsScreen();
  @override
  Widget build(BuildContext context) => const _CenterTextPage('모든 앨범');
}

class _MoreScreen extends StatelessWidget {
  const _MoreScreen();
  @override
  Widget build(BuildContext context) => const _CenterTextPage('더보기');
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
