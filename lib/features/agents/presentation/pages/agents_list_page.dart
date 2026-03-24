import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/utilisateur.dart';
import '../../../../core/services/database_service.dart';
import '../providers/agent_provider.dart';

class AgentsListPage extends ConsumerWidget {
  const AgentsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion des Agents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(agentsProvider),
          ),
        ],
      ),
      body: agentsAsync.when(
        data: (agents) => ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          itemCount: agents.length,
          itemBuilder: (context, index) {
            final agent = agents[index];
            return _AgentCard(agent: agent);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}

class _AgentCard extends ConsumerWidget {
  final Utilisateur agent;

  const _AgentCard({required this.agent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workloadAsync = ref.watch(agentWorkloadProvider(agent.id!));

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.paddingM),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            agent.initiales,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          agent.nomComplet,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(agent.role.label, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            workloadAsync.when(
              data: (workload) => _buildWorkloadRow(workload),
              loading: () => const SizedBox(height: 4, child: LinearProgressIndicator()),
              error: (_, __) => const Text('Erreur stats'),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/agents/${agent.id}'),
      ),
    );
  }

  Widget _buildWorkloadRow(AgentWorkload workload) {
    Color statusColor;
    if (workload.workloadScore > 70) {
      statusColor = AppColors.error;
    } else if (workload.workloadScore > 30) {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.success;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.5)),
          ),
          child: Text(
            'Charge: ${workload.workloadLevel}',
            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${workload.totalTasks} tâches',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
