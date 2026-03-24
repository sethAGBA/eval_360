import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// AppBar personnalisée de l'application
class CustomAppBar extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const CustomAppBar({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.appBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        child: Row(
          children: [
            // Bouton menu (toggle sidebar)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
              tooltip: 'Menu',
            ),

            const SizedBox(width: AppSizes.paddingM),

            // Barre de recherche
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un projet, activité, indicateur...',
                    prefixIcon: const Icon(Icons.search, size: AppSizes.iconM),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                  ),
                  onSubmitted: (value) {
                    // TODO: Implémenter la recherche globale
                    print('Recherche: $value');
                  },
                ),
              ),
            ),

            const SizedBox(width: AppSizes.paddingL),

            // Actions rapides
            _buildActionButton(
              context,
              icon: Icons.add,
              label: 'Nouveau',
              onPressed: () {
                context.push('/projects/new');
              },
            ),

            const SizedBox(width: AppSizes.paddingM),

            // Notifications
            _buildIconButton(
              icon: Icons.notifications_outlined,
              badge: 3,
              onPressed: () {
                // TODO: Afficher les notifications
                print('Notifications');
              },
            ),

            const SizedBox(width: AppSizes.paddingM),

            // Profil utilisateur
            _buildUserMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: AppSizes.iconS),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    int? badge,
    required VoidCallback onPressed,
  }) {
    return Stack(
      children: [
        IconButton(icon: Icon(icon), onPressed: onPressed),
        if (badge != null && badge > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                badge > 9 ? '9+' : badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: const Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingS),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Admin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                'Super Admin',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(width: AppSizes.paddingS),
          const Icon(Icons.arrow_drop_down, size: AppSizes.iconM),
        ],
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: AppSizes.iconS),
              SizedBox(width: AppSizes.paddingM),
              Text('Mon Profil'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: AppSizes.iconS),
              SizedBox(width: AppSizes.paddingM),
              Text('Paramètres'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: AppSizes.iconS, color: AppColors.error),
              SizedBox(width: AppSizes.paddingM),
              Text('Déconnexion', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            // TODO: Naviguer vers le profil
            print('Profil');
            break;
          case 'settings':
            context.go('/settings');
            break;
          case 'logout':
            // TODO: Déconnecter l'utilisateur
            context.go('/login');
            break;
        }
      },
    );
  }
}
