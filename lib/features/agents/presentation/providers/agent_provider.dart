import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/utilisateur.dart';
import '../../../../core/services/database_service.dart';

/// Provider pour la liste des agents
final agentsProvider = FutureProvider<List<Utilisateur>>((ref) async {
  return ref.watch(databaseServiceProvider).getAgents();
});

/// Provider pour les stats de charge d'un agent spécifique
final agentWorkloadProvider = FutureProvider.family<AgentWorkload, int>((ref, agentId) async {
  return ref.watch(databaseServiceProvider).getAgentStats(agentId);
});

/// Provider interne pour DatabaseService
final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService.instance);
