import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/plan_travail.dart';
import '../providers/ptba_detail_provider.dart';
import '../providers/ptba_list_provider.dart';
import '../../../projects/presentation/providers/project_provider.dart';

class PtbaDetailPage extends ConsumerStatefulWidget {
  final int id;

  const PtbaDetailPage({super.key, required this.id});

  @override
  ConsumerState<PtbaDetailPage> createState() => _PtbaDetailPageState();
}

class _PtbaDetailPageState extends ConsumerState<PtbaDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PlanTravail? _ptba;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ptbasAsync = ref.watch(ptbaListProvider);

    return ptbasAsync.when(
      data: (ptbas) {
        _ptba = ptbas.firstWhere((p) => p.id == widget.id, orElse: () => throw Exception('PTBA non trouvé'));
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              _buildHeader(context),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Matrice des Activités', icon: Icon(Icons.table_chart)),
                  Tab(text: 'Jalons & Livrables', icon: Icon(Icons.inventory_2)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActivitesTab(),
                    _buildLivrablesTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Détails du PTBA'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Modifier',
          onPressed: () {
            context.push('/ptba/${widget.id}/edit');
          },
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Exporter en PDF',
          onPressed: () {
            // TODO: Exporter en PDF via ExportService
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fonctionnalité d\'export à venir')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.table_view),
          tooltip: 'Exporter en Excel (Matrice)',
          onPressed: () {
            // TODO: Exporter Matrice en Excel
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fonctionnalité d\'export à venir')),
            );
          },
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (_ptba == null) return const SizedBox.shrink();

    final projectsAsync = ref.watch(projectsProvider);
    final projectName = projectsAsync.when(
      data: (projets) {
        final match = projets.where((p) => p.id == _ptba!.projetId).firstOrNull;
        return match?.titre ?? 'Projet #${_ptba!.projetId}';
      },
      loading: () => 'Chargement...',
      error: (_, __) => 'Erreur',
    );

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      margin: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Année ${_ptba!.annee}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _buildStatusBadge(_ptba!.statut),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            projectName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(height: AppSizes.paddingXL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBudgetStat('Budget État', _ptba!.budgetEtat),
              _buildBudgetStat('Budget PTF', _ptba!.budgetPtf),
              _buildBudgetStat('Budget Total', _ptba!.budgetTotal, isTotal: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStat(String label, double amount, {bool isTotal = false}) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(0)} FCFA',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isTotal ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(StatutPTBA statut) {
    Color color;
    switch (statut) {
      case StatutPTBA.brouillon:
        color = Colors.grey;
      case StatutPTBA.en_attente:
        color = Colors.orange;
      case StatutPTBA.valide:
        color = Colors.green;
      case StatutPTBA.cloture:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        statut.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- TAB: MATRICE DES ACTIVITÉS ---
  Widget _buildActivitesTab() {
    final activitiesAsync = ref.watch(ptbaActivitiesProvider(widget.id));

    return activitiesAsync.when(
      data: (activites) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                children: [
                  Text(
                    '${activites.length} activité(s) planifiée(s)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Ouvrir un modal pour lier une nouvelle activité au PTBA
                    },
                    icon: const Icon(Icons.add_task),
                    label: const Text('Ajouter une Activité'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: activites.isEmpty
                  ? const Center(child: Text('Aucune activité dans ce PTBA.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                      itemCount: activites.length,
                      itemBuilder: (context, index) {
                        final act = activites[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                          child: ListTile(
                            title: Text(act.intitule, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Budget: ${(act.budgetEtat + act.budgetPtf).toStringAsFixed(0)} FCFA (État: ${act.budgetEtat.toStringAsFixed(0)} | PTF: ${act.budgetPtf.toStringAsFixed(0)})'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // TODO: Editer l'activité
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }

  // --- TAB: LIVRABLES ---
  Widget _buildLivrablesTab() {
    return Column(
      children: [
         Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Row(
            children: [
              const Text(
                'Suivi des Jalons / Livrables',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Ouvrir un modal de création de livrable
                },
                icon: const Icon(Icons.add_box),
                label: const Text('Nouveau Livrable'),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Sélectionnez une activité pour gérer ses livrables.',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }
}
