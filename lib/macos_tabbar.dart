import 'package:flutter/material.dart';

const _minTabWidth = 120.0;

class MacosTabData {
  final String id;
  final String title;

  MacosTabData({required this.id, required this.title});
}

class MacosTabbar extends StatefulWidget implements PreferredSizeWidget {
  MacosTabbar({
    super.key,
    required this.tabs,
    this.selectedTabId,
    required this.onTabSelected,
    required this.onTabDeleted,
  })  : assert(tabs.isNotEmpty, 'Tabs must not be empty'),
        assert(
            selectedTabId == null || tabs.any((tab) => tab.id == selectedTabId),
            'Selected tab id must be in tabs'),
        assert(tabs.map((tab) => tab.id).toSet().length == tabs.length,
            'All ids must be unique');

  final List<MacosTabData> tabs;
  final String? selectedTabId;
  final ValueChanged<String> onTabSelected;
  final ValueChanged<String> onTabDeleted;
  @override
  State<MacosTabbar> createState() => _MacosTabbarState();

  @override
  Size get preferredSize => const Size.fromHeight(30);
}

class _MacosTabbarState extends State<MacosTabbar> {
  double scrollOffset = 0.0;

  late List<(int, MacosTabData)> arrangedTabs;
  late (int, MacosTabData) middle;

  void _updateTabs() {
    var selectedIndex = widget.tabs.indexWhere(
      (tab) => tab.id == widget.selectedTabId,
    );

    final indexedTabs = widget.tabs.indexed.toList();
    final firstHalf = indexedTabs.take(selectedIndex).toList();
    middle = indexedTabs.elementAt(selectedIndex);
    final secondHalf =
        indexedTabs.skip(selectedIndex + 1).toList().reversed.toList();

    arrangedTabs = [...firstHalf, ...secondHalf, middle];
  }

  @override
  void initState() {
    _updateTabs();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MacosTabbar oldWidget) {
    _updateTabs();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tabWidth = (width / widget.tabs.length).clamp(
      _minTabWidth,
      double.infinity,
    );
    final maxOffset = widget.tabs.length * tabWidth;

    Widget buildTab((int, MacosTabData) tab) {
      return Positioned(
        bottom: 0,
        top: 0,
        left: getLeftOffset(
          index: tab.$1,
          scrollOffset: scrollOffset,
          width: width,
          tabWidth: tabWidth,
        ),
        child: SizedBox(
          width: tabWidth,
          child: MacosTab(
            title: tab.$2.title,
            isMiddle: tab.$1 == middle.$1,
            onTap: () {
              widget.onTabSelected(tab.$2.id);
            },
            onCloseTap: () {
              widget.onTabDeleted(tab.$2.id);
            },
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ...arrangedTabs.map(buildTab),
        NotificationListener(
          onNotification: (notification) {
            if (notification
                case (ScrollUpdateNotification(metrics: final metrics) ||
                    ScrollMetricsNotification(metrics: final metrics))) {
              setState(() {
                scrollOffset = metrics.pixels;
              });
            }
            return true;
          },
          child: SingleChildScrollView(
            hitTestBehavior: HitTestBehavior.translucent,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: maxOffset,
              height: double.infinity,
            ),
          ),
        ),
      ],
    );
  }
}

double getLeftOffset({
  required int index,
  required double scrollOffset,
  required double width,
  required double tabWidth,
}) {
  final begin = index * tabWidth;

  final newscrollOffset = (begin - scrollOffset);

  return newscrollOffset.clamp(0, width - tabWidth);
}

class MacosTab extends StatelessWidget {
  final String title;

  final bool isMiddle;
  final VoidCallback onTap;
  final VoidCallback onCloseTap;

  const MacosTab({
    super.key,
    required this.title,
    this.isMiddle = false,
    required this.onTap,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isMiddle ? const Color(0xFF363636) : const Color(0xFF1E1E1E);
    final foregroundColor = isMiddle ? Colors.white : const Color(0xFF979797);
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: const Color(0xFF474747), width: 0.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onCloseTap,
              child: Icon(Icons.close, color: foregroundColor, size: 12),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
