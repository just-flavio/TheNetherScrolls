import 'package:flutter/material.dart';
import 'package:thenetherscrolls/core/constants/app_icons.dart';
import 'package:thenetherscrolls/core/widget/widgetIcone.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: AppIcon(AppIcons.schede),
          label: 'Schede',
        ),
        NavigationDestination(
          icon: AppIcon(AppIcons.campagne),
          label: 'Campagne',
        ),
        NavigationDestination(
          icon: AppIcon(AppIcons.dadi),
          label: 'Dadi',
        ),
      ],
    );
  }
}