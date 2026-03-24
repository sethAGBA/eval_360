import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/database/database_helper.dart';

// Modèle pour afficher les utilisateurs
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

/// Provider fictif (pour la démo) de l'année d'exercice active de l'instance
final activeExerciseYearProvider = StateProvider<int>((ref) => DateTime.now().year);

/// Provider fictif (pour la démo) de l'institution
final institutionNameProvider = StateProvider<String>((ref) => 'MDDL / CPDSE-CT');
