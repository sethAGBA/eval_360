import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/commune.dart';
import '../providers/commune_provider.dart';

class CommunesListPage extends ConsumerWidget {
  const CommunesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communesAsync = ref.watch(filteredCommunesProvider);
    final statsAsync = ref.watch(pdcStatsProvider);
    final regionFilter = ref.watch(communeRegionFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi des PDC (Communes du Togo)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(communesProvider),
          ),
          const SizedBox(width: AppSizes.paddingL),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(context, statsAsync),
          _buildFilterBar(context, ref, regionFilter),
          Expanded(
            child: communesAsync.when(
              data: (communes) => _buildCommunesList(context, communes),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erreur: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, AsyncValue<Map<String, double>> statsAsync) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatsCard(
            label: 'Avancement Moyen National',
            value: statsAsync.when(
              data: (s) => '${s['moyenne']?.toStringAsFixed(1)}%',
              error: (_, __) => '--',
              loading: () => '...',
            ),
            icon: Icons.analytics,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref, String? currentRegion) {
    final regions = ['Maritime', 'Plateaux', 'Centrale', 'Kara', 'Savanes'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Toutes Régions'),
              selected: currentRegion == null,
              onSelected: (val) => ref.read(communeRegionFilterProvider.notifier).state = null,
            ),
            const SizedBox(width: 8),
            ...regions.map((r) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(r),
                selected: currentRegion == r,
                onSelected: (val) => ref.read(communeRegionFilterProvider.notifier).state = val ? r : null,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunesList(BuildContext context, List<Commune> communes) {
    if (communes.isEmpty) {
      return const Center(child: Text('Aucune commune trouvée.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: communes.length,
      itemBuilder: (context, index) {
        final commune = communes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSizes.paddingM),
            title: Text(commune.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Région: ${commune.region} | Préfecture: ${commune.prefecture}'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: commune.tauxAvancementPdc / 100,
                        backgroundColor: Colors.grey[200],
                        color: _getColorForProgress(commune.tauxAvancementPdc),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${commune.tauxAvancementPdc.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () {
                // TODO: Dialogue pour mettre à jour le taux
              },
            ),
          ),
        );
      },
    );
  }

  Color _getColorForProgress(double progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }
}

class _StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatsCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 32),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
