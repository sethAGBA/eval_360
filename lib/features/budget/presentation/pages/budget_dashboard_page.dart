import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/projet.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/presentation/providers/budget_provider.dart';
import '../providers/budget_global_provider.dart';

class BudgetDashboardPage extends ConsumerWidget {
  const BudgetDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(globalBudgetStatsProvider);
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi Budgétaire Global'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(globalBudgetStatsProvider);
              ref.invalidate(projectsProvider);
            },
          ),
          ElevatedButton.icon(
            onPressed: () => context.push('/budget/expenses'),
            icon: const Icon(Icons.list_alt),
            label: const Text('Toutes les Dépenses'),
          ).paddingOnly(right: AppSizes.paddingL),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(context, stats),
              const SizedBox(height: AppSizes.paddingXL),
              Text(
                'Consommation par Projet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              projectsAsync.when(
                data: (projects) => _buildProjectsGrid(context, ref, projects),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Erreur: $err'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, Map<String, double> stats) {
    final budgetTotal = stats['budgetTotal'] ?? 0.0;
    final depensesTotal = stats['depensesTotal'] ?? 0.0;
    final solde = stats['solde'] ?? 0.0;
    final ratio = budgetTotal > 0 ? depensesTotal / budgetTotal : 0.0;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildMetricCard(
            context,
            'Budget Global',
            '${budgetTotal.toStringAsFixed(0)} FCFA',
            Icons.account_balance_wallet,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.paddingL),
        Expanded(
          flex: 2,
          child: _buildMetricCard(
            context,
            'Total Dépenses',
            '${depensesTotal.toStringAsFixed(0)} FCFA',
            Icons.payments,
            Colors.orange,
            subtitle: '${(ratio * 100).toStringAsFixed(1)}% consommé',
          ),
        ),
        const SizedBox(width: AppSizes.paddingL),
        Expanded(
          flex: 2,
          child: _buildMetricCard(
            context,
            'Solde Disponible',
            '${solde.toStringAsFixed(0)} FCFA',
            Icons.savings,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsGrid(BuildContext context, WidgetRef ref, List<Projet> projects) {
    if (projects.isEmpty) {
      return const Center(child: Text('Aucun projet actif.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSizes.paddingL,
            mainAxisSpacing: AppSizes.paddingL,
            mainAxisExtent: 180,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return _ProjectBudgetCard(project: project);
          },
        );
      },
    );
  }
}

class _ProjectBudgetCard extends ConsumerWidget {
  final Projet project;

  const _ProjectBudgetCard({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consumptionAsync = ref.watch(budgetConsumptionProvider(project.id!));

    return Card(
      child: InkWell(
        onTap: () => context.push('/projects/${project.id}'),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.titre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Budget: ${project.budgetTotal.toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              consumptionAsync.when(
                data: (consumptionMap) {
                  final totalConsomme = consumptionMap.values.fold(0.0, (a, b) => a + b);
                  final ratio = project.budgetTotal > 0 ? (totalConsomme / project.budgetTotal).clamp(0.0, 1.0) : 0.0;
                  
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(ratio * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('${totalConsomme.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: ratio,
                        backgroundColor: Colors.grey[200],
                        color: ratio > 0.9 ? Colors.red : (ratio > 0.7 ? Colors.orange : AppColors.primary),
                        minHeight: 6,
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => const Text('Erreur calcul'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension PaddingExtension on Widget {
  Widget paddingOnly({double right = 0}) {
    return Padding(padding: EdgeInsets.only(right: right), child: this);
  }
}
