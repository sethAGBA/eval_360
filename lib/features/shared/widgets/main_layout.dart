import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'custom_sidebar.dart';
import 'custom_app_bar.dart';
import 'custom_bottom_bar.dart';

/// Layout principal de l'application avec Sidebar, AppBar et BottomBar
class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSidebarCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // AppBar
          CustomAppBar(onMenuPressed: _toggleSidebar),

          // Body avec Sidebar
          Expanded(
            child: Row(
              children: [
                // Sidebar
                CustomSidebar(isCollapsed: _isSidebarCollapsed),

                // Contenu principal
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),

          // BottomBar
          const CustomBottomBar(),
        ],
      ),
    );
  }
}
