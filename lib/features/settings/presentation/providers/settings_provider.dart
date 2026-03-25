import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/models/app_config.dart';

// ============================================================================
// CONSTANTES POUR LES CLÉES SHARED PREFERENCES
// ============================================================================
const String _kActiveYear = 'settings_active_year';
const String _kInstitutionName = 'settings_institution_name';

// ============================================================================
// MODÈLE UTILISATEUR (pour l'onglet Utilisateurs & Rôles)
// ============================================================================
class UserConfig {
  final int id;
  final String matricule;
  final String nomComplet;
  final String role;
  final bool actif;

  const UserConfig({
    required this.id,
    required this.matricule,
    required this.nomComplet,
    required this.role,
    required this.actif,
  });
}

// ============================================================================
// PROVIDERS UTILISATEURS (lecture BDD SQLite)
// ============================================================================

/// Provider pour récupérer la liste des utilisateurs depuis la BDD SQLite
final usersListProvider = FutureProvider<List<UserConfig>>((ref) async {
  final db = await DatabaseHelper.instance.database;
  final maps = await db.query('utilisateurs_acces', orderBy: 'nom ASC, prenom ASC');
  
  return maps.map((map) => UserConfig(
    id: map['id'] as int,
    matricule: (map['username'] ?? '') as String,
    nomComplet: '${map['nom']} ${map['prenom']}',
    role: (map['role'] ?? 'Agent') as String,
    actif: (map['actif'] as int? ?? 1) == 1,
  )).toList();
});

// ============================================================================
// PROVIDERS PARAMÈTRES PERSISTÉS (SharedPreferences)
// ============================================================================

/// Notifier pour l'année d'exercice active — persiste dans SharedPreferences
class ActiveYearNotifier extends StateNotifier<int> {
  ActiveYearNotifier() : super(DateTime.now().year) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_kActiveYear);
    if (saved != null) state = saved;
  }

  Future<void> set(int year) async {
    state = year;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kActiveYear, year);
  }
}

final activeExerciseYearProvider = StateNotifierProvider<ActiveYearNotifier, int>(
  (ref) => ActiveYearNotifier(),
);

/// Notifier pour le nom d'institution — persiste dans SharedPreferences
class InstitutionNameNotifier extends StateNotifier<String> {
  InstitutionNameNotifier() : super('MDDL / CPDSE-CT') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kInstitutionName);
    if (saved != null) state = saved;
  }

  Future<void> set(String name) async {
    state = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kInstitutionName, name);
  }
}


final institutionNameProvider = StateNotifierProvider<InstitutionNameNotifier, String>(
  (ref) => InstitutionNameNotifier(),
);

// ============================================================================
// PROVIDER CONFIGURATION APPLICATION (SQLite)
// ============================================================================

class AppConfigNotifier extends StateNotifier<AsyncValue<AppConfig>> {
  AppConfigNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => DatabaseService.instance.getAppConfig());
  }

  Future<void> updateConfig(AppConfig config) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await DatabaseService.instance.saveAppConfig(config);
      return config;
    });
  }
}

final appConfigProvider = StateNotifierProvider<AppConfigNotifier, AsyncValue<AppConfig>>(
  (ref) => AppConfigNotifier(),
);
