import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../providers/bottom_bar_providers.dart';

/// BottomBar affichant les statistiques temps réel
class CustomBottomBar extends ConsumerWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(bottomBarStatsProvider);

    return Container(
      height: AppSizes.bottomBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        child: statsAsync.when(
          data: (stats) => Row(
            children: [
              _buildStat(
                icon: Icons.folder,
                label: '${stats.activeProjectsCount} projet${stats.activeProjectsCount > 1 ? 's' : ''} actif${stats.activeProjectsCount > 1 ? 's' : ''}',
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.paddingXL),
              _buildStat(
                icon: Icons.attach_money,
                label: '${stats.budgetExecutionPercentage.toStringAsFixed(1)}% exécution budgétaire',
                color: AppColors.success,
              ),
              const SizedBox(width: AppSizes.paddingXL),
              _buildStat(
                icon: Icons.warning_amber,
                label: '${stats.criticalRisksCount} risque${stats.criticalRisksCount > 1 ? 's' : ''} critique${stats.criticalRisksCount > 1 ? 's' : ''}',
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSizes.paddingXL),
              _buildStat(
                icon: Icons.notifications,
                label: '${stats.pendingTasksCount} tâche${stats.pendingTasksCount > 1 ? 's' : ''} en attente',
                color: AppColors.error,
              ),

              const Spacer(),

              // Statut synchronisation
              _buildSyncStatus(),
            ],
          ),
          loading: () => Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textTertiary),
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              const Text(
                'Chargement des statistiques...',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          error: (error, stack) => Row(
            children: [
              const Icon(Icons.error, size: AppSizes.iconS, color: AppColors.error),
              const SizedBox(width: AppSizes.paddingS),
              const Text(
                'Erreur lors du chargement',
                style: TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ],
          ),
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
