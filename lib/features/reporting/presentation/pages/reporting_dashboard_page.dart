import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../providers/reporting_provider.dart';

class ReportingDashboardPage extends ConsumerWidget {
  const ReportingDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalAsync = ref.watch(globalStatsProvider);
    final budgetAsync = ref.watch(budgetByProjectProvider);
    final selectedYear = ref.watch(statsYearFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reporting & Statistiques'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedYear,
              items: List.generate(4, (i) => DateTime.now().year - i)
                  .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                  .toList(),
              onChanged: (y) {
                if (y != null) ref.read(statsYearFilterProvider.notifier).state = y;
              },
            ),
          ),
          const SizedBox(width: AppSizes.paddingL),
        ],
      ),
      body: globalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKpiRow(context, stats),
              const SizedBox(height: AppSizes.paddingL),
              _buildSectionTitle('Taux d\'exécution budgétaire par projet'),
              budgetAsync.when(
                data: (items) => _buildBudgetChart(context, items),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erreur: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiRow(BuildContext context, GlobalStats stats) {
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA ', decimalDigits: 0);

    return Row(
      children: [
        Expanded(child: _KpiCard(
          label: 'Projets Actifs',
          value: '${stats.activeProjects} / ${stats.totalProjects}',
          icon: Icons.folder_open,
          color: AppColors.primary,
        )),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(child: _KpiCard(
          label: 'Budget Total',
          value: fmt.format(stats.budgetTotal),
          icon: Icons.account_balance,
          color: Colors.indigo,
        )),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(child: _KpiCard(
          label: 'Budget Exécuté',
          value: fmt.format(stats.budgetExecute),
          icon: Icons.payments,
          color: Colors.teal,
          footer: '${stats.tauxExecutionBudget.toStringAsFixed(1)}%',
        )),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(child: _KpiCard(
          label: 'Bénéficiaires',
          value: '${stats.totalBeneficiaires}',
          icon: Icons.people_alt,
          color: Colors.orange,
        )),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(child: _KpiCard(
          label: 'Taux Indicateurs',
          value: '${stats.tauxIndicateurs.toStringAsFixed(1)}%',
          icon: Icons.bar_chart,
          color: Colors.green,
        )),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBudgetChart(BuildContext context, List<ProjectBudgetStat> items) {
    if (items.isEmpty) {
      return const Text('Aucune donnée de projet disponible.');
    }
    final fmt = NumberFormat.compact(locale: 'fr_FR');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          children: items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.projectName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${fmt.format(item.budgetExecute)} / ${fmt.format(item.budgetTotal)} FCFA',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.tauxExecution.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item.tauxExecution > 75 ? Colors.green : item.tauxExecution > 40 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (item.tauxExecution / 100).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                  color: item.tauxExecution > 75 ? Colors.green : item.tauxExecution > 40 ? Colors.orange : Colors.red,
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? footer;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            if (footer != null) ...[
              const SizedBox(height: 4),
              Text(footer!, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}
