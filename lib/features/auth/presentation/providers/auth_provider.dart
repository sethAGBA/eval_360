import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/models/utilisateur.dart';
import '../../../../core/services/auth_service.dart';

// ============================================================================
// PROVIDERS POUR L'AUTHENTIFICATION
// ============================================================================

/// Provider pour l'AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

/// Provider pour l'utilisateur actuellement connecté
final currentUserProvider = StateProvider<Utilisateur?>((ref) {
  return AuthService.instance.currentUser;
});

/// Provider pour vérifier si l'utilisateur est connecté
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// Provider pour vérifier si l'utilisateur est admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return user.role == UserRole.superAdmin || user.role == UserRole.admin;
});

/// Provider pour vérifier une permission spécifique
final hasPermissionProvider = Provider.family<bool, String>((ref, permission) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return user.hasPermission(permission);
});

/// Provider pour vérifier l'accès à un projet
final hasProjectAccessProvider = Provider.family<bool, int>((ref, projectId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return user.hasAccessToProject(projectId);
});
