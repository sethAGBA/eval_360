import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../projects/presentation/providers/project_detail_providers.dart';

class ActiviteSelectorDialog extends ConsumerStatefulWidget {
  const ActiviteSelectorDialog({super.key});

  @override
  ConsumerState<ActiviteSelectorDialog> createState() => _ActiviteSelectorDialogState();
}

class _ActiviteSelectorDialogState extends ConsumerState<ActiviteSelectorDialog> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activitesAsync = ref.watch(allActivitesProvider);

    return AlertDialog(
      title: const Text('Sélectionner une activité PTBA'),
      contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher par code ou intitulé...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Expanded(
              child: activitesAsync.when(
                data: (activites) {
                  final filtered = activites.where((a) {
                    return a.intitule.toLowerCase().contains(_searchQuery) ||
                        a.codeActivite.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Aucune activité trouvée'),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final act = filtered[index];
                      return ListTile(
                        title: Text(
                          act.intitule,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Code: ${act.codeActivite}'),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.assignment, color: AppColors.primary, size: 20),
                        ),
                        onTap: () => Navigator.pop(context, act),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Erreur: $err')),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
