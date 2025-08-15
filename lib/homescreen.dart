import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // TODO: 실제 그룹 데이터로 교체
  final List<String> _groups = [
    'SSH 스크립트', '새로운 단축어 1', 'VPN 설정', 'ipTIME WOL',
    'HTML viewer', '사전', '네이버', '카카오 하이닉스',
    '새로운 단축어', '○', '여행사진', '스터디'
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeShortcutsStyleGrid(groups: _groups),
      const _FriendsScreen(),
      const _AllAlbumsScreen(),
      const _MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: pages),
          Positioned(
            left: 0, right: 0, bottom: 0,
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

/// 상단 대제목(Pacifico) + 검색바 + 2열 컬러 타일
class _HomeShortcutsStyleGrid extends StatelessWidget {
  const _HomeShortcutsStyleGrid({required this.groups});
  final List<String> groups;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    // 단축어 앱 느낌의 컬러 그라디언트 팔레트
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
        // 상단 헤더 (Pacifico "Grouping" + + 버튼)
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Grouping',
                    style: GoogleFonts.pacifico(
                      fontSize: 42, // 단축어 앱처럼 크게
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

        // 검색 바 (옵션: 필요 없으면 SliverToBoxAdapter 블록 제거)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: _SearchPill(),
          ),
        ),

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
                  // TODO: 그룹 상세(앨범/일정)로 이동
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Open $name')));
                },
                onMore: () {
                  // TODO: 타일의 옵션 메뉴
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('More: $name')));
                },
              );
            }, childCount: groups.length),
          ),
        ),
      ],
    );
  }
}

class _SearchPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: Colors.black54),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('검색', style: TextStyle(color: Colors.black54, fontSize: 15)),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, size: 20, color: Colors.black45),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: '음성 검색',
          ),
        ],
      ),
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
                // 좌상단 아이콘
                Positioned(
                  top: 4, left: 4,
                  child: Icon(leadingIcon, size: 28, color: Colors.white.withOpacity(0.95)),
                ),
                // 우상단 점3개
                Positioned(
                  top: 0, right: 0,
                  child: GestureDetector(
                    onTap: onMore,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.more_horiz_rounded, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // 좌하단 타이틀
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
                        shadows: [Shadow(blurRadius: 0.5, color: Colors.black26)],
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

/// iOS 느낌의 하단 블러 네비게이션 (아이콘만, 위->아래로 블러 강해짐)
class _BlurBottomNavBar extends StatelessWidget {
  const _BlurBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

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
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.40),
                Colors.white.withOpacity(0.75),
                Colors.white.withOpacity(0.95),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavIcon(icon: Icons.home_rounded,          selected: currentIndex == 0, onTap: () => onTap(0)),
                  _NavIcon(icon: Icons.group_rounded,         selected: currentIndex == 1, onTap: () => onTap(1)),
                  _NavIcon(icon: Icons.photo_library_rounded, selected: currentIndex == 2, onTap: () => onTap(2)),
                  _NavIcon(icon: Icons.more_horiz_rounded,    selected: currentIndex == 3, onTap: () => onTap(3)),
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
  const _NavIcon({required this.icon, required this.selected, required this.onTap});
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

// -------------------- Placeholder Screens --------------------
class _FriendsScreen extends StatelessWidget {
  const _FriendsScreen();
  @override
  Widget build(BuildContext context) => const _CenterTextPage('친구');
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
        child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

