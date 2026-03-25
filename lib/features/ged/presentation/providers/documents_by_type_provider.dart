import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/document.dart';
import '../../../../core/services/database_service.dart';

/// Provider pour récupérer les documents filtrés par type
final documentsByTypeProvider = FutureProvider.family<List<Document>, TypeDocument>((ref, type) async {
  return await DatabaseService.instance.getDocuments(type: type);
});

/// Provider pour récupérer tous les rapports de stage
final rapportsStageProvider = FutureProvider<List<Document>>((ref) async {
  return await DatabaseService.instance.getDocuments(type: TypeDocument.rapportStage);
});
