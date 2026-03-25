import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/tache.dart';
import '../../../agents/presentation/providers/agent_provider.dart';
import '../../../projects/presentation/providers/activite_provider.dart';
import '../providers/task_provider.dart';

class TasksKanbanPage extends ConsumerWidget {
  const TasksKanbanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion des Tâches (Kanban)'),
        actions: [
          ref.watch(agentsProvider).when(
            data: (agents) => DropdownButton<int?>(
              value: ref.watch(taskFiltersProvider).agentId,
              hint: const Text('Filtrer par agent'),
              underline: const SizedBox.shrink(),
              dropdownColor: Colors.white,
              items: [
                const DropdownMenuItem(value: null, child: Text('Tous les agents')),
                ...agents.map((a) => DropdownMenuItem(
                  value: a.id,
                  child: Text(a.nomComplet),
                )),
              ],
              onChanged: (val) {
                ref.read(taskFiltersProvider.notifier).update(
                  (state) => state.copyWith(agentId: val),
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(tasksProvider),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle'),
          ).paddingOnly(right: AppSizes.paddingL),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) => _buildKanbanBoard(context, ref, tasks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildKanbanBoard(BuildContext context, WidgetRef ref, List<Tache> tasks) {
    return Row(
      children: [
        _buildColumn(context, ref, 'À FAIRE', TacheStatut.aFaire, 
            tasks.where((t) => t.statut == TacheStatut.aFaire).toList()),
        _buildColumn(context, ref, 'EN COURS', TacheStatut.enCours, 
            tasks.where((t) => t.statut == TacheStatut.enCours).toList()),
        _buildColumn(context, ref, 'TERMINÉ', TacheStatut.termine, 
            tasks.where((t) => t.statut == TacheStatut.termine).toList()),
        _buildColumn(context, ref, 'SUSPENDU', TacheStatut.suspendu, 
            tasks.where((t) => t.statut == TacheStatut.suspendu).toList()),
      ],
    );
  }

  Widget _buildColumn(BuildContext context, WidgetRef ref, String title, TacheStatut statut, List<Tache> tasks) {
    return Expanded(
      child: DragTarget<Tache>(
        onAccept: (tache) {
          if (tache.statut != statut) {
            ref.read(taskActionProvider.notifier).moveTask(tache, statut);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty 
                  ? AppColors.primary.withOpacity(0.05) 
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: candidateData.isNotEmpty 
                  ? Border.all(color: AppColors.primary.withOpacity(0.2)) 
                  : null,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${tasks.length}', style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(context, ref, tasks[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Tache tache) {
    return Draggable<Tache>(
      data: tache,
      feedback: SizedBox(
        width: 280,
        child: _TaskCardContent(tache: tache, isFeedback: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _TaskCardContent(tache: tache),
      ),
      child: _TaskCardContent(
        tache: tache,
        onTap: () => _showEditTaskDialog(context, ref, tache),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    context.push('/tasks/new');
  }

  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Tache tache) {
    context.push('/tasks/edit/${tache.id}');
  }
}

class _TaskCardContent extends ConsumerWidget {
  final Tache tache;
  final bool isFeedback;
  final VoidCallback? onTap;

  const _TaskCardContent({required this.tache, this.isFeedback = false, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentsProvider);
    final activitesAsync = ref.watch(activitesProvider);
    
    final taskAgents = agentsAsync.whenOrNull(data: (list) => list.where((a) => tache.agentIds.contains(a.id)).toList()) ?? [];
    final activite = tache.activiteId != null 
        ? activitesAsync.whenOrNull(data: (list) => list.firstWhere((a) => a.id == tache.activiteId))
        : null;

    return Card(
      elevation: isFeedback ? 8 : 1,
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusS)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      tache.titre,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  _buildPriorityBadge(tache.priorite),
                ],
              ),
              if (tache.description != null && tache.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  tache.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
              if (activite != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    activite.codeActivite,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (tache.dateEcheance != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${tache.dateEcheance!.day}/${tache.dateEcheance!.month}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  if (tache.pourcentageAvancement > 0)
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: tache.pourcentageAvancement / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  if (taskAgents.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          taskAgents.length == 1 
                              ? taskAgents.first.nomComplet.split(' ').first
                              : '${taskAgents.first.nomComplet.split(' ').first} +${taskAgents.length - 1}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TachePriorite priorite) {
    Color color;
    switch (priorite) {
      case TachePriorite.haute: color = AppColors.error; break;
      case TachePriorite.moyenne: color = AppColors.warning; break;
      case TachePriorite.basse: color = AppColors.success; break;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

extension PaddingExtension on Widget {
  Widget paddingOnly({double right = 0}) {
    return Padding(padding: EdgeInsets.only(right: right), child: this);
  }
}
