import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/document.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../providers/ged_provider.dart';

class GedPage extends ConsumerWidget {
  const GedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final filters = ref.watch(gedFiltersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion Documentaire (GED)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(documentsProvider),
          ),
          const SizedBox(width: AppSizes.paddingL),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(context, ref, filters, projectsAsync),
          Expanded(
            child: documentsAsync.when(
              data: (docs) => _buildDocumentGrid(context, docs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erreur: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implémenter l'upload ou création de nouveau document
        },
        label: const Text('Nouveau Document'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref, GedFilters filters, AsyncValue<List<dynamic>> projectsAsync) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un document...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
              ),
              onChanged: (val) => ref.read(gedFiltersProvider.notifier).update((s) => s.copyWith(search: val)),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: DropdownButtonFormField<TypeDocument>(
              value: filters.type,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Type de document'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tous les types')),
                ...TypeDocument.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))),
              ],
              onChanged: (val) => ref.read(gedFiltersProvider.notifier).update((s) => s.copyWith(type: val)),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: projectsAsync.when(
              data: (projects) => DropdownButtonFormField<int>(
                value: filters.projetId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Projet'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tous les projets')),
                  ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.titre))),
                ],
                onChanged: (val) => ref.read(gedFiltersProvider.notifier).update((s) => s.copyWith(projetId: val)),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentGrid(BuildContext context, List<Document> docs) {
    if (docs.isEmpty) {
      return const Center(child: Text('Aucun document trouvé.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: AppSizes.paddingM,
        mainAxisSpacing: AppSizes.paddingM,
        childAspectRatio: 0.8,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return _DocumentCard(doc: doc);
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Document doc;

  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Ouvrir le document
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingS),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getIconForDocument(doc.type), size: 48, color: _getColorForDocument(doc.type)),
              const SizedBox(height: 8),
              Text(
                doc.titre,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                doc.type.label,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy').format(doc.dateDocument),
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForDocument(TypeDocument type) {
    switch (type) {
      case TypeDocument.tdr: return Icons.description;
      case TypeDocument.ordreMission: return Icons.flight_takeoff;
      case TypeDocument.rapportHebdo: return Icons.view_week;
      case TypeDocument.rapportMensuel: return Icons.calendar_month;
      case TypeDocument.compteRendu: return Icons.article;
      case TypeDocument.rapportStage: return Icons.school;
      case TypeDocument.autre: return Icons.file_present;
    }
  }

  Color _getColorForDocument(TypeDocument type) {
    switch (type) {
      case TypeDocument.tdr: return Colors.blue;
      case TypeDocument.ordreMission: return Colors.orange;
      case TypeDocument.rapportHebdo: return Colors.green;
      case TypeDocument.rapportMensuel: return Colors.teal;
      case TypeDocument.compteRendu: return Colors.indigo;
      case TypeDocument.rapportStage: return Colors.purple;
      case TypeDocument.autre: return Colors.grey;
    }
  }
}
