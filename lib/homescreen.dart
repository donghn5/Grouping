import 'dart:ui';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // TODO: 실제 그룹 데이터로 교체
  final List<String> _groups = List.generate(12, (i) => 'Group ${i + 1}');

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeGroupsGrid(groups: _groups),
      const _FriendsScreen(),
      const _AllAlbumsScreen(),
      const _MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 탭 전환 시 상태유지
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),

          // 하단 블러 내비게이션 (아이콘만)
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

/// 메인(홈) 탭: 좌측 상단 로고 + 2열 그리드 타일
class _HomeGroupsGrid extends StatelessWidget {
  const _HomeGroupsGrid({required this.groups});

  final List<String> groups;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  // 좌측 상단 로고 (grouping 글자)
                  Text(
                    'grouping',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  // 여분 아이콘(알림 등) 넣고 싶으면 여기
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + padding.bottom + 80),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final name = groups[index];
                return _GroupTile(
                  title: name,
                  onTap: () {
                    // TODO: 그룹 상세(앨범/일정)로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open $name')),
                    );
                  },
                );
              },
              childCount: groups.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,          // 2 * n 타일
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,     // 타일 비율 살짝 정사각형보다 큼
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 썸네일 자리(임시 그래디언트)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFDEE7FF),
                            Color(0xFFEFF5FF),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.folder_shared_rounded, size: 36, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '앨범 · 일정',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.5),
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
      // 블러 영역 잘리도록
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,   // 좌우 블러는 적당히
          sigmaY: 18,   // 위->아래 더 강하게 보이도록 Y쪽을 크게
        ),
        child: Container(
          padding: EdgeInsets.only(bottom: bottom > 0 ? bottom : 12),
          decoration: BoxDecoration(
            // 투명도 있는 그Radient: 위에서 아래로 점점 진해짐
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.40),
                Colors.white.withOpacity(0.75),
                Colors.white.withOpacity(0.95),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border(
              top: BorderSide(color: Colors.black.withOpacity(0.06)),
            ),
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
                    label: '홈',
                    selected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavIcon(
                    icon: Icons.group_rounded,
                    label: '친구',
                    selected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavIcon(
                    icon: Icons.photo_library_rounded,
                    label: '앨범',
                    selected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavIcon(
                    icon: Icons.more_horiz_rounded,
                    label: '더보기',
                    selected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
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
  const _NavIcon({
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
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : Colors.black54;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(height: 4),
            // 아이콘만 표시 원한다면 이 Text는 주석 처리해도 됨
            // 요구사항이 "아이콘만"이라면 아래 한 줄을 제거하세요.
            // Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

// -------------------- Placeholder Screens --------------------

class _FriendsScreen extends StatelessWidget {
  const _FriendsScreen();

  @override
  Widget build(BuildContext context) {
    return const _CenterTextPage('친구');
  }
}

class _AllAlbumsScreen extends StatelessWidget {
  const _AllAlbumsScreen();

  @override
  Widget build(BuildContext context) {
    return const _CenterTextPage('모든 앨범');
  }
}

class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    return const _CenterTextPage('더보기');
  }
}

class _CenterTextPage extends StatelessWidget {
  const _CenterTextPage(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
