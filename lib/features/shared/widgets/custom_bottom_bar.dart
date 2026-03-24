import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// BottomBar affichant les statistiques temps réel
class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.bottomBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        child: Row(
          children: [
            _buildStat(
              icon: Icons.folder,
              label: '12 projets actifs',
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSizes.paddingXL),
            _buildStat(
              icon: Icons.attach_money,
              label: '68% exécution budgétaire',
              color: AppColors.success,
            ),
            const SizedBox(width: AppSizes.paddingXL),
            _buildStat(
              icon: Icons.warning_amber,
              label: '2 risques critiques',
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSizes.paddingXL),
            _buildStat(
              icon: Icons.notifications,
              label: '3 alertes',
              color: AppColors.error,
            ),

            const Spacer(),

            // Statut synchronisation
            _buildSyncStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconS, color: color),
        const SizedBox(width: AppSizes.paddingS),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSyncStatus() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSizes.paddingS),
        const Text(
          'Synchronisé',
          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
