import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/models/document.dart';
import '../../../../core/services/database_service.dart';

/// Filtres pour la GED
class GedFilters {
  final int? projetId;
  final TypeDocument? type;
  final String? search;

  const GedFilters({this.projetId, this.type, this.search});

  GedFilters copyWith({int? projetId, TypeDocument? type, String? search}) {
    return GedFilters(
      projetId: projetId ?? this.projetId,
      type: type ?? this.type,
      search: search ?? this.search,
    );
  }
}

/// Provider pour l'état des filtres de la GED
final gedFiltersProvider = StateProvider<GedFilters>((ref) {
  return const GedFilters();
});

/// Provider pour récupérer les documents filtrés
final documentsProvider = FutureProvider<List<Document>>((ref) async {
  final filters = ref.watch(gedFiltersProvider);
  
  var documents = await DatabaseService.instance.getDocuments(
    projetId: filters.projetId,
    type: filters.type,
  );

  if (filters.search != null && filters.search!.isNotEmpty) {
    final search = filters.search!.toLowerCase();
    documents = documents.where((doc) {
      return doc.titre.toLowerCase().contains(search) || 
             (doc.referenceBoite?.toLowerCase().contains(search) ?? false);
    }).toList();
  }

  return documents;
});

/// Provider pour les actions sur les documents
final documentActionProvider = StateProvider<int?>((ref) => null);
// Note: On pourrait ajouter un Notifier plus complexe pour le renommage, suppression, etc.
