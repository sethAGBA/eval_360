import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/utilisateur.dart';
import '../../../../core/services/database_service.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../providers/agent_provider.dart';

class AgentDetailPage extends ConsumerWidget {
  final int agentId;

  const AgentDetailPage({super.key, required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentsProvider);
    final workloadAsync = ref.watch(agentWorkloadProvider(agentId));
    final tasksAsync = ref.watch(tasksProvider); // We'll filter this

    return agentsAsync.when(
      data: (agents) {
        final agent = agents.firstWhere((a) => a.id == agentId);
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(agent),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(agent),
                      const SizedBox(height: AppSizes.paddingXL),
                      workloadAsync.when(
                        data: (w) => _buildStatsSection(w),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Erreur stats'),
                      ),
                      const SizedBox(height: AppSizes.paddingXL),
                      const Text(
                        'Tâches Assignées',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                    ],
                  ),
                ),
              ),
              tasksAsync.when(
                data: (tasks) {
                  final agentTasks = tasks.where((t) => t.agentId == agentId).toList();
                  if (agentTasks.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(child: Text('Aucune tâche assignée.')),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTaskItem(agentTasks[index]),
                      childCount: agentTasks.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SliverToBoxAdapter(child: Text('Erreur tâches')),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Erreur: $err'))),
    );
  }

  Widget _buildSliverAppBar(Utilisateur agent) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          agent.nomComplet,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        background: Container(color: Colors.white),
      ),
    );
  }

  Widget _buildInfoSection(Utilisateur agent) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            _buildInfoRow(Icons.email, 'Email', agent.email),
            _buildInfoRow(Icons.badge, 'Rôle', agent.role.label),
            _buildInfoRow(Icons.person, 'Username', agent.username),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AgentWorkload w) {
    return Row(
      children: [
        _buildStatCard('Total', w.totalTasks.toString(), Colors.blue),
        _buildStatCard('En Cours', w.enCours.toString(), Colors.orange),
        _buildStatCard('Score Charge', '${w.workloadScore.toInt()}%', _getScoreColor(w.workloadScore)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score > 70) return AppColors.error;
    if (score > 30) return AppColors.warning;
    return AppColors.success;
  }

  Widget _buildTaskItem(dynamic tache) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 4),
      child: Card(
        child: ListTile(
          title: Text(tache.titre),
          subtitle: Text('Status: ${tache.statut.label}'),
          trailing: Text('${tache.pourcentageAvancement.toInt()}%'),
        ),
      ),
    );
  }
}
