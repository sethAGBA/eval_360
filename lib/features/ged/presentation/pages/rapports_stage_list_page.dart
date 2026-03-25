import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../providers/documents_by_type_provider.dart';

class RapportsStageListPage extends ConsumerWidget {
  const RapportsStageListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rapportsAsync = ref.watch(rapportsStageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rapports de Stage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Liste des Rapports de Stage',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/processus/rapport-stage'),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau Rapport'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            Expanded(
              child: rapportsAsync.when(
                data: (documents) {
                  if (documents.isEmpty) {
                    return const Center(child: Text('Aucun Rapport de Stage trouvé.'));
                  }
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final doc = documents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.school, color: Colors.white),
                          ),
                          title: Text(doc.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Soumis le: ${doc.createdAt.toLocal().toString().split(' ')[0]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.indigo),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export PDF en développement')));
                                },
                                tooltip: 'Générer PDF',
                              ),
                            ],
                          ),
                        ),
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
    );
  }
}
