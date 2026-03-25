import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/document.dart';
import '../providers/documents_by_type_provider.dart';

class OrdresMissionListPage extends ConsumerWidget {
  const OrdresMissionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordsAsync = ref.watch(documentsByTypeProvider(TypeDocument.ordreMission));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ordres de Mission (ORD)'),
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
                  'Vos Ordres de Mission',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/processus/ordre-mission'),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvel ORD'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            Expanded(
              child: ordsAsync.when(
                data: (documents) {
                  if (documents.isEmpty) {
                    return const Center(child: Text('Aucun Ordre de Mission trouvé.'));
                  }
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final doc = documents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.orangeAccent,
                            child: Icon(Icons.flight_takeoff, color: Colors.white),
                          ),
                          title: Text(doc.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Créé le: ${doc.createdAt.toLocal().toString().split(' ')[0]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
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
