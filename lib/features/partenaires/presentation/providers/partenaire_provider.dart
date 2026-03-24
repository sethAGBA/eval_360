import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/models/partenaire.dart';
import '../../../../core/services/database_service.dart';

/// Provider pour la liste des partenaires
final partenairesProvider = FutureProvider.family<List<Partenaire>, bool>((ref, actifSeulement) async {
  return await DatabaseService.instance.getPartenaires(actifSeulement: actifSeulement);
});

/// Provider de filtre actif/inactif
final partenaireShowInactifProvider = StateProvider<bool>((ref) => false);
