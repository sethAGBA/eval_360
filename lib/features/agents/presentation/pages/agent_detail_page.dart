import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/utilisateur.dart';
import '../../../../core/services/database_service.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../../core/models/tache.dart';
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
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/agents/$agentId/edit'),
              ),
            ],
          ),
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
                  final agentTasks = tasks.where((t) => t.agentIds.contains(agentId)).toList();
                  if (agentTasks.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(child: Text('Aucune tâche assignée.')),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTaskItem(context, agentTasks[index]),
                      childCount: agentTasks.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SliverToBoxAdapter(child: Text('Erreur tâches')),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSizes.paddingL, AppSizes.paddingXL, AppSizes.paddingL, AppSizes.paddingM),
                  child: Text(
                    'Historique des Tâches',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              tasksAsync.when(
                data: (tasks) {
                  final completedTasks = tasks
                      .where((t) => t.agentIds.contains(agentId) && t.statut == TacheStatut.termine)
                      .toList();
                  if (completedTasks.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.paddingL),
                        child: Text('Aucune tâche terminée.', style: TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildHistoryItem(context, completedTasks[index]),
                      childCount: completedTasks.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
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
            if (agent.matricule != null)
              _buildInfoRow(Icons.badge, 'Matricule', agent.matricule!),
            _buildInfoRow(Icons.email, 'Email', agent.email),
            _buildInfoRow(Icons.security, 'Rôle', agent.role.label),
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

  Widget _buildTaskItem(BuildContext context, dynamic tache) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 4),
      child: Card(
        child: ListTile(
          onTap: () => context.push('/tasks/edit/${tache.id}'),
          title: Text(tache.titre),
          subtitle: Text('Status: ${tache.statut.label}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(tache.statut.name).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${tache.pourcentageAvancement.toInt()}%',
              style: TextStyle(
                color: _getStatusColor(tache.statut.name),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, dynamic tache) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 4),
      child: Card(
        color: Colors.grey[50],
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          title: Text(tache.titre, style: const TextStyle(color: AppColors.textSecondary)),
          subtitle: Text('Terminée le: ${tache.updatedAt.toString().split(' ')[0]}'),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'termine':
        return AppColors.success;
      case 'en_cours':
        return AppColors.primary;
      case 'a_faire':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}
