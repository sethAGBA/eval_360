import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

/// Sidebar de navigation avec animations et design moderne
class CustomSidebar extends StatefulWidget {
  final bool isCollapsed;

  const CustomSidebar({super.key, this.isCollapsed = false});

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  String? _hoveredPath;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: widget.isCollapsed
          ? AppSizes.sidebarCollapsedWidth
          : AppSizes.sidebarWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sidebarBg, AppColors.sidebarBg.withOpacity(0.95)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec animation
          _buildHeader(),

          const SizedBox(height: AppSizes.paddingL),

          // Menu items avec scroll
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Vue d'ensemble
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    path: '/dashboard',
                    isActive: currentPath == '/dashboard',
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Gestion de Projets
                  _buildMenuItem(
                    context,
                    icon: Icons.folder_rounded,
                    label: 'Projets',
                    path: '/projects',
                    isActive: currentPath.startsWith('/projects'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.account_tree_rounded,
                    label: 'Cadre Logique',
                    path: '/logical-framework',
                    isActive: currentPath.startsWith('/logical-framework'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Suivi & Évaluation
                  _buildMenuItem(
                    context,
                    icon: Icons.show_chart_rounded,
                    label: 'Indicateurs',
                    path: '/indicators',
                    isActive: currentPath.startsWith('/indicators'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.assignment_rounded,
                    label: 'Activités',
                    path: '/activities',
                    isActive: currentPath.startsWith('/activities'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.map_rounded,
                    label: 'Missions Terrain',
                    path: '/field-missions',
                    isActive: currentPath.startsWith('/field-missions'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.assessment_rounded,
                    label: 'Évaluations',
                    path: '/evaluations',
                    isActive: currentPath.startsWith('/evaluations'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Gestion Financière
                  _buildMenuItem(
                    context,
                    icon: Icons.attach_money_rounded,
                    label: 'Budget',
                    path: '/budget',
                    isActive: currentPath.startsWith('/budget'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.receipt_long_rounded,
                    label: 'Dépenses',
                    path: '/expenses',
                    isActive: currentPath.startsWith('/expenses'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.request_quote_rounded,
                    label: 'Demandes de Fonds',
                    path: '/fund-requests',
                    isActive: currentPath.startsWith('/fund-requests'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Risques & Problèmes
                  _buildMenuItem(
                    context,
                    icon: Icons.warning_rounded,
                    label: 'Risques',
                    path: '/risks',
                    isActive: currentPath.startsWith('/risks'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.bug_report_rounded,
                    label: 'Problèmes',
                    path: '/issues',
                    isActive: currentPath.startsWith('/issues'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Rapports & Documentation
                  _buildMenuItem(
                    context,
                    icon: Icons.description_rounded,
                    label: 'Rapports',
                    path: '/reports',
                    isActive: currentPath.startsWith('/reports'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.library_books_rounded,
                    label: 'Bibliothèque',
                    path: '/library',
                    isActive: currentPath.startsWith('/library'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Parties Prenantes
                  _buildMenuItem(
                    context,
                    icon: Icons.people_rounded,
                    label: 'Parties Prenantes',
                    path: '/stakeholders',
                    isActive: currentPath.startsWith('/stakeholders'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.campaign_rounded,
                    label: 'Communication',
                    path: '/communication',
                    isActive: currentPath.startsWith('/communication'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Ressources
                  _buildMenuItem(
                    context,
                    icon: Icons.shopping_cart_rounded,
                    label: 'Approvisionnements',
                    path: '/procurement',
                    isActive: currentPath.startsWith('/procurement'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.groups_rounded,
                    label: 'Ressources Humaines',
                    path: '/hr',
                    isActive: currentPath.startsWith('/hr'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _buildMenuItem(
                    context,
                    icon: Icons.inventory_2_rounded,
                    label: 'Équipements',
                    path: '/equipment',
                    isActive: currentPath.startsWith('/equipment'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Capitalisation
                  _buildMenuItem(
                    context,
                    icon: Icons.lightbulb_rounded,
                    label: 'Leçons Apprises',
                    path: '/lessons-learned',
                    isActive: currentPath.startsWith('/lessons-learned'),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Analytics
                  _buildMenuItem(
                    context,
                    icon: Icons.analytics_rounded,
                    label: 'Analytics',
                    path: '/analytics',
                    isActive: currentPath.startsWith('/analytics'),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingM,
                    ),
                    child: Divider(
                      color: AppColors.sidebarHover.withOpacity(0.3),
                      thickness: 1,
                      height: 1,
                    ),
                  ),

                  // Administration
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_rounded,
                    label: 'Paramètres',
                    path: '/settings',
                    isActive: currentPath.startsWith('/settings'),
                  ),
                ],
              ),
            ),
          ),

          // Footer avec version ou info
          if (!widget.isCollapsed) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: AppSizes.appBarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo animé
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'E',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Titre avec animation
          if (!widget.isCollapsed) ...[
            const SizedBox(width: AppSizes.paddingM),
            Flexible(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isCollapsed ? 0 : 1,
                child: Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String path,
    required bool isActive,
  }) {
    final isHovered = _hoveredPath == path;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredPath = path),
      onExit: (_) => setState(() => _hoveredPath = null),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(left: isActive ? 4 : 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go(path),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCollapsed
                    ? AppSizes.paddingS
                    : AppSizes.paddingM,
                vertical: AppSizes.paddingM,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.sidebarActive
                    : isHovered
                    ? AppColors.sidebarHover.withOpacity(0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: isActive
                    ? Border(
                        left: BorderSide(color: AppColors.primary, width: 3),
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône avec animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..scale(isHovered || isActive ? 1.1 : 1.0),
                    child: Icon(
                      icon,
                      color: isActive
                          ? AppColors.sidebarTextActive
                          : isHovered
                          ? AppColors.sidebarTextActive.withOpacity(0.8)
                          : AppColors.sidebarText,
                      size: AppSizes.iconM,
                    ),
                  ),

                  // Label avec animation
                  if (!widget.isCollapsed) ...[
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isActive
                              ? AppColors.sidebarTextActive
                              : isHovered
                              ? AppColors.sidebarTextActive.withOpacity(0.8)
                              : AppColors.sidebarText,
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                          letterSpacing: 0.1,
                        ),
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],

                  // Indicateur actif
                  if (isActive && !widget.isCollapsed)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: AppSizes.paddingS),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.sidebarHover.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.sidebarText.withOpacity(0.5),
          ),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppColors.sidebarText.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
