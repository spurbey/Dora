import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

int locationToTabIndex(String location) {
  if (location.startsWith(Routes.liveHub)) {
    return 1;
  }
  if (location.startsWith(Routes.trips)) {
    return 2;
  }
  if (location.startsWith(Routes.profile)) {
    return 3;
  }
  return 0;
}

String tabIndexToRoute(int index) {
  switch (index) {
    case 0:
      return Routes.feed;
    case 1:
      return Routes.liveHub;
    case 2:
      return Routes.trips;
    case 3:
      return Routes.profile;
    default:
      return Routes.feed;
  }
}

class NavigationShell extends StatelessWidget {
  const NavigationShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = locationToTabIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: _CustomTabBar(
        currentIndex: currentIndex,
        onTap: (index) => context.go(tabIndexToRoute(index)),
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  const _CustomTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = <_TabItemData>[
      _TabItemData(label: 'Feed', icon: Icons.home_outlined),
      _TabItemData(label: 'Live', icon: Icons.radio_button_checked_outlined),
      _TabItemData(label: 'My Trips', icon: Icons.book_outlined),
      _TabItemData(label: 'Profile', icon: Icons.person_outline),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _TabButton(
                    data: items[i],
                    selected: currentIndex == i,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _TabItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.accent : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Semantics(
        button: true,
        selected: selected,
        label: data.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.borderLg,
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: selected ? AppColors.accentSoft : Colors.transparent,
                borderRadius: AppRadius.borderLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(data.icon, color: foreground, size: 22),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
}

class _TabItemData {
  const _TabItemData({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}
