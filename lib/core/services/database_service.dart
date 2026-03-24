import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/projet.dart';
import '../models/bailleur.dart';
import '../models/zone_intervention.dart';
import '../models/utilisateur.dart';
import '../models/beneficiaire.dart';
import '../models/cadre_logique.dart';
import '../models/indicateur.dart';
import '../models/activite.dart';
import '../models/budget_ligne.dart';
import '../models/depense.dart';
import '../models/donnee_collecte.dart';

/// Service centralisé pour toutes les opérations de base de données
/// Fournit des méthodes métier spécifiques pour chaque module
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============================================================================
  // PROJETS
  // ============================================================================

  /// Récupérer tous les projets avec filtres optionnels
  Future<List<Projet>> getProjects({
    ProjetStatut? statut,
    int? bailleurId,
    String? secteur,
    DateTime? dateDebutMin,
    DateTime? dateDebutMax,
    String? searchQuery,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      String sql = '';
      final args = <dynamic>[];

      // Filtre par bailleur (nécessite une jointure)
      if (bailleurId != null) {
        sql = 'SELECT p.* FROM ${DatabaseTables.projets} p';
        sql +=
            ' INNER JOIN ${DatabaseTables.projetBailleurs} pb ON p.${ProjetsColumns.id} = pb.projet_id';
        sql += ' WHERE pb.bailleur_id = ?';
        args.add(bailleurId);

        // Appliquer les autres filtres sur l'alias 'p'
        if (statut != null) {
          sql += ' AND p.${ProjetsColumns.statut} = ?';
          args.add(statut.name);
        }

        if (secteur != null && secteur.isNotEmpty) {
          sql += ' AND p.${ProjetsColumns.secteurIntervention} = ?';
          args.add(secteur);
        }

        if (dateDebutMin != null) {
          sql += ' AND p.${ProjetsColumns.dateDebutPrevue} >= ?';
          args.add(dateDebutMin.toIso8601String());
        }

        if (dateDebutMax != null) {
          sql += ' AND p.${ProjetsColumns.dateDebutPrevue} <= ?';
          args.add(dateDebutMax.toIso8601String());
        }

        if (searchQuery != null && searchQuery.isNotEmpty) {
          sql +=
              ' AND (p.${ProjetsColumns.codeProjet} LIKE ? OR p.${ProjetsColumns.titre} LIKE ?)';
          args.add('%$searchQuery%');
          args.add('%$searchQuery%');
        }
      } else {
        sql = 'SELECT * FROM ${DatabaseTables.projets} WHERE 1=1';

        if (statut != null) {
          sql += ' AND ${ProjetsColumns.statut} = ?';
          args.add(statut.name);
        }

        if (secteur != null && secteur.isNotEmpty) {
          sql += ' AND ${ProjetsColumns.secteurIntervention} = ?';
          args.add(secteur);
        }

        if (dateDebutMin != null) {
          sql += ' AND ${ProjetsColumns.dateDebutPrevue} >= ?';
          args.add(dateDebutMin.toIso8601String());
        }

        if (dateDebutMax != null) {
          sql += ' AND ${ProjetsColumns.dateDebutPrevue} <= ?';
          args.add(dateDebutMax.toIso8601String());
        }

        if (searchQuery != null && searchQuery.isNotEmpty) {
          sql +=
              ' AND (${ProjetsColumns.codeProjet} LIKE ? OR ${ProjetsColumns.titre} LIKE ?)';
          args.add('%$searchQuery%');
          args.add('%$searchQuery%');
        }
      }

      // Tri
      if (orderBy != null) {
        sql += ' ORDER BY $orderBy ${ascending ? 'ASC' : 'DESC'}';
      } else {
        sql += ' ORDER BY ${ProjetsColumns.createdAt} DESC';
      }

      final results = await _db.rawQuery(sql, args);
      return results.map((map) => Projet.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting projects: $e');
      rethrow;
    }
  }

  /// Récupérer un projet par ID
  Future<Projet?> getProjectById(int id) async {
    try {
      final result = await _db.queryById(DatabaseTables.projets, id);
      return result != null ? Projet.fromMap(result) : null;
    } catch (e) {
      debugPrint('❌ Error getting project by id: $e');
      rethrow;
    }
  }

  /// Créer un nouveau projet
  Future<int> createProject(Projet projet) async {
    try {
      return await _db.insert(DatabaseTables.projets, projet.toMap());
    } catch (e) {
      debugPrint('❌ Error creating project: $e');
      rethrow;
    }
  }

  /// Mettre à jour un projet
  Future<void> updateProject(Projet projet) async {
    try {
      await _db.update(DatabaseTables.projets, projet.toMap());
    } catch (e) {
      debugPrint('❌ Error updating project: $e');
      rethrow;
    }
  }

  /// Supprimer un projet
  Future<void> deleteProject(int id) async {
    try {
      await _db.delete(DatabaseTables.projets, id);
    } catch (e) {
      debugPrint('❌ Error deleting project: $e');
      rethrow;
    }
  }

  /// Lier une zone à un projet
  Future<void> linkZoneToProject({
    required int projectId,
    required int zoneId,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert(DatabaseTables.projetZones, {
        'projet_id': projectId,
        'zone_id': zoneId,
      });
    } catch (e) {
      debugPrint('❌ Error linking zone to project: $e');
      rethrow;
    }
  }

  /// Obtenir les statistiques d'un projet
  Future<ProjectStats> getProjectStats(int projectId) async {
    try {
      final db = await _db.database;

      // 1. Nombre d'indicateurs
      final indCountResult = await db.rawQuery(
        'SELECT COUNT(*) as total FROM ${DatabaseTables.indicateurs} WHERE projet_id = ?',
        [projectId],
      );
      final totalIndicateurs = Sqflite.firstIntValue(indCountResult) ?? 0;

      // 2. Indicateurs atteints
      final indReachedResult = await db.rawQuery(
        '''
        SELECT COUNT(*) as reached 
        FROM ${DatabaseTables.indicateurs} i 
        WHERE i.projet_id = ? 
        AND i.cible_finale IS NOT NULL
        AND (
          SELECT COALESCE(SUM(valeur_mesuree), 0) 
          FROM ${DatabaseTables.donneesCollecte} d 
          WHERE d.indicateur_id = i.id AND d.valide = 1
        ) >= i.cible_finale
        ''',
        [projectId],
      );
      final indicateursAtteints = Sqflite.firstIntValue(indReachedResult) ?? 0;

      // 3. Nombre d'activités
      final actCountResult = await db.rawQuery(
        'SELECT COUNT(*) as total FROM ${DatabaseTables.activites} WHERE projet_id = ?',
        [projectId],
      );
      final totalActivites = Sqflite.firstIntValue(actCountResult) ?? 0;

      // 4. Budget total vs exécuté
      final projectResult = await db.query(
        DatabaseTables.projets,
        columns: [ProjetsColumns.budgetTotal],
        where: 'id = ?',
        whereArgs: [projectId],
      );
      final budgetTotal = projectResult.isNotEmpty
          ? (projectResult.first[ProjetsColumns.budgetTotal] as num).toDouble()
          : 0.0;

      final expenseResult = await db.rawQuery(
        "SELECT SUM(montant) as total FROM ${DatabaseTables.depensesDecaissements} WHERE projet_id = ? AND statut_validation != 'rejete'",
        [projectId],
      );
      final budgetExecute =
          (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

      // 5. Bénéficiaires (Cibles totales vs Réalisés par activités)
      final benefCiblesResult = await db.rawQuery(
        'SELECT SUM(nombre_prevu) as total FROM ${DatabaseTables.beneficiaires} WHERE projet_id = ?',
        [projectId],
      );
      final totalBeneficiaires = Sqflite.firstIntValue(benefCiblesResult) ?? 0;

      final benefAtteintsResult = await db.rawQuery(
        'SELECT SUM(nombre_beneficiaires_atteints) as total FROM ${DatabaseTables.activites} WHERE projet_id = ?',
        [projectId],
      );
      final beneficiairesAtteints =
          Sqflite.firstIntValue(benefAtteintsResult) ?? 0;

      return ProjectStats(
        nombreIndicateurs: totalIndicateurs,
        nombreIndicateursAtteints: indicateursAtteints,
        nombreActivites: totalActivites,
        budgetTotal: budgetTotal,
        budgetExecute: budgetExecute,
        nombreRisques: 0,
        nombreRisquesCritiques: 0,
        nombreBeneficiaires: totalBeneficiaires,
        nombreBeneficiairesAtteints: beneficiairesAtteints,
      );
    } catch (e) {
      debugPrint('❌ Error getting project stats: $e');
      rethrow;
    }
  }

  /// Obtenir le nombre de projets par statut
  Future<Map<ProjetStatut, int>> getProjectCountByStatus() async {
    try {
      final sql =
          '''
        SELECT ${ProjetsColumns.statut}, COUNT(*) as count
        FROM ${DatabaseTables.projets}
        GROUP BY ${ProjetsColumns.statut}
      ''';

      final results = await _db.rawQuery(sql);
      final counts = <ProjetStatut, int>{};

      for (final row in results) {
        final statut = ProjetStatut.values.firstWhere(
          (e) => e.name == row[ProjetsColumns.statut],
          orElse: () => ProjetStatut.pipeline,
        );
        counts[statut] = row['count'] as int;
      }

      return counts;
    } catch (e) {
      debugPrint('❌ Error getting project count by status: $e');
      rethrow;
    }
  }

  // ============================================================================
  // BAILLEURS
  // ============================================================================

  /// Récupérer tous les bailleurs
  Future<List<Bailleur>> getBailleurs({
    BailleurType? type,
    String? pays,
  }) async {
    try {
      String sql = 'SELECT * FROM ${DatabaseTables.bailleurs} WHERE 1=1';
      final args = <dynamic>[];

      if (type != null) {
        sql += ' AND ${BailleursColumns.type} = ?';
        args.add(type.name);
      }

      if (pays != null && pays.isNotEmpty) {
        sql += ' AND ${BailleursColumns.pays} = ?';
        args.add(pays);
      }

      sql += ' ORDER BY ${BailleursColumns.nom} ASC';

      final results = await _db.rawQuery(sql, args);
      return results.map((map) => Bailleur.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting bailleurs: $e');
      rethrow;
    }
  }

  /// Récupérer un bailleur par ID
  Future<Bailleur?> getBailleurById(int id) async {
    try {
      final result = await _db.queryById(DatabaseTables.bailleurs, id);
      return result != null ? Bailleur.fromMap(result) : null;
    } catch (e) {
      debugPrint('❌ Error getting bailleur by id: $e');
      rethrow;
    }
  }

  /// Créer un nouveau bailleur
  Future<int> createBailleur(Bailleur bailleur) async {
    try {
      return await _db.insert(DatabaseTables.bailleurs, bailleur.toMap());
    } catch (e) {
      debugPrint('❌ Error creating bailleur: $e');
      rethrow;
    }
  }

  /// Mettre à jour un bailleur
  Future<void> updateBailleur(Bailleur bailleur) async {
    try {
      await _db.update(DatabaseTables.bailleurs, bailleur.toMap());
    } catch (e) {
      debugPrint('❌ Error updating bailleur: $e');
      rethrow;
    }
  }

  /// Supprimer un bailleur
  Future<void> deleteBailleur(int id) async {
    try {
      await _db.delete(DatabaseTables.bailleurs, id);
    } catch (e) {
      debugPrint('❌ Error deleting bailleur: $e');
      rethrow;
    }
  }

  /// Lier un bailleur à un projet
  Future<void> linkBailleurToProject({
    required int projetId,
    required int bailleurId,
    required String role,
    required double montantContribution,
    required String devise,
    DateTime? dateConvention,
  }) async {
    try {
      final projetBailleur = ProjetBailleur(
        projetId: projetId,
        bailleurId: bailleurId,
        role: role,
        montantContribution: montantContribution,
        devise: devise,
        dateConvention: dateConvention,
      );

      await _db.insert(DatabaseTables.projetBailleurs, projetBailleur.toMap());
    } catch (e) {
      debugPrint('❌ Error linking bailleur to project: $e');
      rethrow;
    }
  }

  /// Récupérer les bailleurs d'un projet
  Future<List<Bailleur>> getBailleursByProject(int projetId) async {
    try {
      final sql =
          '''
        SELECT b.* FROM ${DatabaseTables.bailleurs} b
        INNER JOIN ${DatabaseTables.projetBailleurs} pb ON b.${BailleursColumns.id} = pb.bailleur_id
        WHERE pb.projet_id = ?
      ''';

      final results = await _db.rawQuery(sql, [projetId]);
      return results.map((map) => Bailleur.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting bailleurs by project: $e');
      rethrow;
    }
  }

  /// Mettre à jour les bailleurs d'un projet
  Future<void> updateProjectBailleurs(
    int projectId,
    List<int> bailleurIds,
  ) async {
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        // 1. Supprimer les liens existants
        await txn.delete(
          DatabaseTables.projetBailleurs,
          where: 'projet_id = ?',
          whereArgs: [projectId],
        );

        // 2. Ajouter les nouveaux liens
        for (final bailleurId in bailleurIds) {
          await txn.insert(DatabaseTables.projetBailleurs, {
            'projet_id': projectId,
            'bailleur_id': bailleurId,
            'role': 'Financement',
            'montant_contribution': 0.0,
            'devise': r'$',
          });
        }
      });
    } catch (e) {
      debugPrint('❌ Error updating project bailleurs: $e');
      rethrow;
    }
  }

  /// Mettre à jour les zones d'un projet
  Future<void> updateProjectZones(int projectId, List<int> zoneIds) async {
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        // 1. Supprimer les liens existants
        await txn.delete(
          DatabaseTables.projetZones,
          where: 'projet_id = ?',
          whereArgs: [projectId],
        );

        // 2. Ajouter les nouveaux liens
        for (final zoneId in zoneIds) {
          await txn.insert(DatabaseTables.projetZones, {
            'projet_id': projectId,
            'zone_id': zoneId,
          });
        }
      });
    } catch (e) {
      debugPrint('❌ Error updating project zones: $e');
      rethrow;
    }
  }

  // ============================================================================
  // ZONES D'INTERVENTION
  // ============================================================================

  /// Récupérer toutes les zones
  Future<List<ZoneIntervention>> getZones({
    String? pays,
    String? region,
  }) async {
    try {
      String sql = 'SELECT * FROM ${DatabaseTables.zones} WHERE 1=1';
      final args = <dynamic>[];

      if (pays != null && pays.isNotEmpty) {
        sql += ' AND ${ZonesColumns.pays} = ?';
        args.add(pays);
      }

      if (region != null && region.isNotEmpty) {
        sql += ' AND ${ZonesColumns.region} = ?';
        args.add(region);
      }

      sql += ' ORDER BY ${ZonesColumns.pays}, ${ZonesColumns.region}';

      final results = await _db.rawQuery(sql, args);
      return results.map((map) => ZoneIntervention.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting zones: $e');
      rethrow;
    }
  }

  /// Récupérer une zone par ID
  Future<ZoneIntervention?> getZoneById(int id) async {
    try {
      final result = await _db.queryById(DatabaseTables.zones, id);
      return result != null ? ZoneIntervention.fromMap(result) : null;
    } catch (e) {
      debugPrint('❌ Error getting zone by id: $e');
      rethrow;
    }
  }

  /// Créer une nouvelle zone
  Future<int> createZone(ZoneIntervention zone) async {
    try {
      return await _db.insert(DatabaseTables.zones, zone.toMap());
    } catch (e) {
      debugPrint('❌ Error creating zone: $e');
      rethrow;
    }
  }

  /// Mettre à jour une zone
  Future<void> updateZone(ZoneIntervention zone) async {
    try {
      await _db.update(DatabaseTables.zones, zone.toMap());
    } catch (e) {
      debugPrint('❌ Error updating zone: $e');
      rethrow;
    }
  }

  /// Supprimer une zone
  Future<void> deleteZone(int id) async {
    try {
      await _db.delete(DatabaseTables.zones, id);
    } catch (e) {
      debugPrint('❌ Error deleting zone: $e');
      rethrow;
    }
  }

  /// Récupérer les zones d'un projet
  Future<List<ZoneIntervention>> getZonesByProject(int projetId) async {
    try {
      final sql =
          '''
        SELECT z.* FROM ${DatabaseTables.zones} z
        INNER JOIN ${DatabaseTables.projetZones} pz ON z.id = pz.zone_id
        WHERE pz.projet_id = ?
      ''';

      final results = await _db.rawQuery(sql, [projetId]);
      return results.map((map) => ZoneIntervention.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting zones by project: $e');
      rethrow;
    }
  }

  // ============================================================================
  // UTILISATEURS
  // ============================================================================

  /// Récupérer tous les utilisateurs
  Future<List<Utilisateur>> getUtilisateurs({
    UserRole? role,
    bool? actif,
  }) async {
    try {
      String sql = 'SELECT * FROM ${DatabaseTables.utilisateurs} WHERE 1=1';
      final args = <dynamic>[];

      if (role != null) {
        sql += ' AND ${UtilisateursColumns.role} = ?';
        args.add(role.name);
      }

      if (actif != null) {
        sql += ' AND ${UtilisateursColumns.actif} = ?';
        args.add(actif ? 1 : 0);
      }

      sql +=
          ' ORDER BY ${UtilisateursColumns.nom}, ${UtilisateursColumns.prenom}';

      final results = await _db.rawQuery(sql, args);
      return results.map((map) => Utilisateur.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting utilisateurs: $e');
      rethrow;
    }
  }

  /// Récupérer un utilisateur par ID
  Future<Utilisateur?> getUtilisateurById(int id) async {
    try {
      final result = await _db.queryById(DatabaseTables.utilisateurs, id);
      return result != null ? Utilisateur.fromMap(result) : null;
    } catch (e) {
      debugPrint('❌ Error getting utilisateur by id: $e');
      rethrow;
    }
  }

  /// Récupérer un utilisateur par username
  Future<Utilisateur?> getUtilisateurByUsername(String username) async {
    try {
      final sql =
          '''
        SELECT * FROM ${DatabaseTables.utilisateurs}
        WHERE ${UtilisateursColumns.username} = ?
        LIMIT 1
      ''';

      final results = await _db.rawQuery(sql, [username]);
      return results.isNotEmpty ? Utilisateur.fromMap(results.first) : null;
    } catch (e) {
      debugPrint('❌ Error getting utilisateur by username: $e');
      rethrow;
    }
  }

  /// Créer un nouvel utilisateur
  Future<int> createUtilisateur(Utilisateur utilisateur) async {
    try {
      return await _db.insert(DatabaseTables.utilisateurs, utilisateur.toMap());
    } catch (e) {
      debugPrint('❌ Error creating utilisateur: $e');
      rethrow;
    }
  }

  /// Mettre à jour un utilisateur
  Future<void> updateUtilisateur(Utilisateur utilisateur) async {
    try {
      await _db.update(DatabaseTables.utilisateurs, utilisateur.toMap());
    } catch (e) {
      debugPrint('❌ Error updating utilisateur: $e');
      rethrow;
    }
  }

  /// Supprimer un utilisateur
  Future<void> deleteUtilisateur(int id) async {
    try {
      await _db.delete(DatabaseTables.utilisateurs, id);
    } catch (e) {
      debugPrint('❌ Error deleting utilisateur: $e');
      rethrow;
    }
  }

  /// Mettre à jour la dernière connexion
  Future<void> updateLastLogin(int userId) async {
    try {
      final sql =
          '''
        UPDATE ${DatabaseTables.utilisateurs}
        SET ${UtilisateursColumns.derniereConnexion} = ?
        WHERE ${UtilisateursColumns.id} = ?
      ''';

      await _db.execute(sql, [DateTime.now().toIso8601String(), userId]);
    } catch (e) {
      debugPrint('❌ Error updating last login: $e');
      rethrow;
    }
  }

  // ============================================================================
  // STATISTIQUES GLOBALES
  // ============================================================================

  /// Obtenir les statistiques du dashboard principal
  Future<DashboardStats> getDashboardStats({
    String? secteur,
    int? annee,
  }) async {
    try {
      // Obtenir la liste des IDs des projets correspondant aux filtres
      final filteredProjects = await getProjects(
        secteur: secteur,
        dateDebutMin: annee != null ? DateTime(annee, 1, 1) : null,
        dateDebutMax: annee != null ? DateTime(annee, 12, 31) : null,
      );
      final projectIds = filteredProjects.map((p) => p.id!).toList();

      if (projectIds.isEmpty && (secteur != null || annee != null)) {
        return const DashboardStats(
          totalProjects: 0,
          activeProjects: 0,
          budgetTotal: 0.0,
          budgetExecute: 0.0,
          totalBeneficiaires: 0,
          tauxIndicateurs: 0.0,
          nombreBailleurs: 0,
          nombreUtilisateurs: 0,
        );
      }

      final idPlaceholder = projectIds.isEmpty
          ? ''
          : ' WHERE projet_id IN (${projectIds.join(',')})';

      // Nombre total de projets
      final totalProjects = filteredProjects.length;

      // Nombre de projets actifs
      final activeProjects = filteredProjects
          .where((p) => p.statut == ProjetStatut.actif)
          .length;

      // Budget total
      final budgetTotal = filteredProjects.fold<double>(
        0,
        (sum, p) => sum + p.budgetTotal,
      );

      // Budget exécuté
      final expenseSql =
          "SELECT SUM(montant) as total FROM ${DatabaseTables.depensesDecaissements}${idPlaceholder.isEmpty ? '' : idPlaceholder}${idPlaceholder.isEmpty ? " WHERE statut_validation != 'rejete'" : " AND statut_validation != 'rejete'"}";
      final expenseResult = await _db.rawQuery(expenseSql);
      final budgetExecute =
          (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

      // Total bénéficiaires
      final benefSql =
          'SELECT SUM(nombre_prevu) as total FROM ${DatabaseTables.beneficiaires}$idPlaceholder';
      final benefResult = await _db.rawQuery(benefSql);
      final totalBeneficiaires = Sqflite.firstIntValue(benefResult) ?? 0;

      // Taux d'indicateurs atteints global
      final indSql =
          'SELECT COUNT(*) FROM ${DatabaseTables.indicateurs}$idPlaceholder';
      final totalIndResult = await _db.rawQuery(indSql);
      final totalInd = Sqflite.firstIntValue(totalIndResult) ?? 0;

      double tauxIndicateurs = 0.0;
      if (totalInd > 0) {
        final reachedIndSql =
            '''
          SELECT COUNT(*) 
          FROM ${DatabaseTables.indicateurs} i 
          WHERE i.cible_finale IS NOT NULL 
          ${projectIds.isEmpty ? '' : 'AND i.projet_id IN (${projectIds.join(',')})'}
          AND (
            SELECT COALESCE(SUM(valeur_mesuree), 0) 
            FROM ${DatabaseTables.donneesCollecte} d 
            WHERE d.indicateur_id = i.id AND d.valide = 1
          ) >= i.cible_finale
        ''';
        final reachedIndResult = await _db.rawQuery(reachedIndSql);
        final reachedInd = Sqflite.firstIntValue(reachedIndResult) ?? 0;
        tauxIndicateurs = (reachedInd / totalInd) * 100;
      }

      return DashboardStats(
        totalProjects: totalProjects,
        activeProjects: activeProjects,
        budgetTotal: budgetTotal,
        budgetExecute: budgetExecute,
        totalBeneficiaires: totalBeneficiaires,
        tauxIndicateurs: tauxIndicateurs,
        nombreBailleurs: (await getBailleurs()).length,
        nombreUtilisateurs: (await getUtilisateurs(actif: true)).length,
      );
    } catch (e) {
      debugPrint('❌ Error getting dashboard stats: $e');
      rethrow;
    }
  }
  // ============================================================================
  // BÉNÉFICIAIRES
  // ============================================================================

  /// Récupérer les bénéficiaires d'un projet
  Future<List<Beneficiaire>> getBeneficiairesByProject(int projetId) async {
    try {
      final sql =
          '''
        SELECT * FROM ${DatabaseTables.beneficiaires}
        WHERE projet_id = ?
        ORDER BY type, groupe_cible
      ''';

      final results = await _db.rawQuery(sql, [projetId]);
      return results.map((map) => Beneficiaire.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting beneficiaires: $e');
      rethrow;
    }
  }

  /// Créer un bénéficiaire
  Future<int> createBeneficiaire(Beneficiaire beneficiaire) async {
    try {
      return await _db.insert(
        DatabaseTables.beneficiaires,
        beneficiaire.toMap(),
      );
    } catch (e) {
      debugPrint('❌ Error creating beneficiaire: $e');
      rethrow;
    }
  }

  /// Mettre à jour un bénéficiaire
  Future<void> updateBeneficiaire(Beneficiaire beneficiaire) async {
    try {
      await _db.update(DatabaseTables.beneficiaires, beneficiaire.toMap());
    } catch (e) {
      debugPrint('❌ Error updating beneficiaire: $e');
      rethrow;
    }
  }

  /// Supprimer tous les bénéficiaires d'un projet
  Future<void> deleteBeneficiairesByProject(int projetId) async {
    try {
      final db = await _db.database;
      await db.delete(
        DatabaseTables.beneficiaires,
        where: 'projet_id = ?',
        whereArgs: [projetId],
      );
    } catch (e) {
      debugPrint('❌ Error deleting beneficiaires: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CADRE LOGIQUE
  // ============================================================================

  /// Récupérer le cadre logique d'un projet
  Future<List<CadreLogique>> getCadreLogiqueByProject(int projetId) async {
    try {
      final sql =
          '''
        SELECT * FROM ${DatabaseTables.cadreLogique}
        WHERE projet_id = ?
        ORDER BY niveau, ordre
      ''';

      final results = await _db.rawQuery(sql, [projetId]);
      return results.map((map) => CadreLogique.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting cadre logique: $e');
      rethrow;
    }
  }

  /// Créer un élément du cadre logique
  Future<int> createCadreLogique(CadreLogique element) async {
    try {
      return await _db.insert(DatabaseTables.cadreLogique, element.toMap());
    } catch (e) {
      debugPrint('❌ Error creating cadre logique: $e');
      rethrow;
    }
  }

  /// Mettre à jour un élément du cadre logique
  Future<void> updateCadreLogique(CadreLogique element) async {
    try {
      await _db.update(DatabaseTables.cadreLogique, element.toMap());
    } catch (e) {
      debugPrint('❌ Error updating cadre logique: $e');
      rethrow;
    }
  }

  // ============================================================================
  // INDICATEURS
  // ============================================================================

  /// Récupérer les indicateurs d'un projet
  Future<List<Indicateur>> getIndicateursByProject(int projetId) async {
    try {
      final sql =
          '''
        SELECT i.*, 
        (SELECT COALESCE(SUM(v.valeur_mesuree), 0) 
         FROM ${DatabaseTables.donneesCollecte} v 
         WHERE v.indicateur_id = i.id AND v.valide = 1) as valeur_actuelle
        FROM ${DatabaseTables.indicateurs} i
        WHERE i.projet_id = ?
        ORDER BY i.niveau, i.code_indicateur
      ''';

      final results = await _db.rawQuery(sql, [projetId]);
      return results.map((map) => Indicateur.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting indicateurs: $e');
      rethrow;
    }
  }

  /// Créer un indicateur
  Future<int> createIndicateur(Indicateur indicateur) async {
    try {
      return await _db.insert(DatabaseTables.indicateurs, indicateur.toMap());
    } catch (e) {
      debugPrint('❌ Error creating indicateur: $e');
      rethrow;
    }
  }

  /// Mettre à jour un indicateur
  Future<void> updateIndicateur(Indicateur indicateur) async {
    try {
      await _db.update(DatabaseTables.indicateurs, indicateur.toMap());
    } catch (e) {
      debugPrint('❌ Error updating indicateur: $e');
      rethrow;
    }
  }

  // ============================================================================
  // COLLECTE DE DONNÉES (INDICATEURS)
  // ============================================================================

  /// Enregistrer une nouvelle donnée de collecte
  Future<int> createDonneeCollecte(DonneeCollecte donnee) async {
    try {
      final db = await _db.database;
      return await db.insert(DatabaseTables.donneesCollecte, donnee.toMap());
    } catch (e) {
      debugPrint('❌ Error creating donnee collecte: $e');
      rethrow;
    }
  }

  /// Récupérer les données de collecte pour un indicateur
  Future<List<DonneeCollecte>> getDonneesByIndicateur(int indicateurId) async {
    try {
      final db = await _db.database;
      final results = await db.query(
        DatabaseTables.donneesCollecte,
        where: 'indicateur_id = ?',
        whereArgs: [indicateurId],
        orderBy: 'date_collecte DESC',
      );
      return results.map((map) => DonneeCollecte.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting donnees by indicateur: $e');
      rethrow;
    }
  }

  // ============================================================================
  // ACTIVITÉS
  // ============================================================================

  /// Récupérer les activités d'un projet
  Future<List<Activite>> getActivitesByProject(
    int projetId, {
    StatutActivite? statut,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    try {
      String sql =
          'SELECT * FROM ${DatabaseTables.activites} WHERE projet_id = ?';
      final args = <dynamic>[projetId];

      if (statut != null) {
        sql += ' AND statut = ?';
        args.add(statut.name);
      }

      if (dateDebut != null) {
        sql += ' AND date_fin_prevue >= ?';
        args.add(dateDebut.toIso8601String());
      }

      if (dateFin != null) {
        sql += ' AND date_debut_prevue <= ?';
        args.add(dateFin.toIso8601String());
      }

      sql += ' ORDER BY date_debut_prevue';

      final results = await _db.rawQuery(sql, args);
      return results.map((map) => Activite.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting activites: $e');
      rethrow;
    }
  }

  /// Créer une activité
  Future<int> createActivite(Activite activite) async {
    try {
      return await _db.insert(DatabaseTables.activites, activite.toMap());
    } catch (e) {
      debugPrint('❌ Error creating activite: $e');
      rethrow;
    }
  }

  /// Mettre à jour une activité
  Future<void> updateActivite(Activite activite) async {
    try {
      await _db.update(DatabaseTables.activites, activite.toMap());
    } catch (e) {
      debugPrint('❌ Error updating activite: $e');
      rethrow;
    }
  }

  /// Obtenir les statistiques des activités d'un projet
  Future<ActiviteStats> getActiviteStats(int projetId) async {
    try {
      final sql =
          '''
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN statut = 'terminee' THEN 1 ELSE 0 END) as terminees,
          SUM(CASE WHEN statut = 'enCours' THEN 1 ELSE 0 END) as enCours,
          SUM(CASE WHEN statut = 'retard' THEN 1 ELSE 0 END) as enRetard,
          AVG(pourcentage_avancement) as avancementMoyen,
          SUM(budget_estime) as budgetTotal,
          SUM(budget_realise) as budgetRealise
        FROM ${DatabaseTables.activites}
        WHERE projet_id = ?
      ''';

      final result = await _db.rawQuery(sql, [projetId]);
      final row = result.first;

      return ActiviteStats(
        total: row['total'] as int,
        terminees: row['terminees'] as int,
        enCours: row['enCours'] as int,
        enRetard: row['enRetard'] as int,
        avancementMoyen: (row['avancementMoyen'] as num?)?.toDouble() ?? 0.0,
        budgetTotal: (row['budgetTotal'] as num?)?.toDouble() ?? 0.0,
        budgetRealise: (row['budgetRealise'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      debugPrint('❌ Error getting activite stats: $e');
      rethrow;
    }
  }

  // ============================================================================
  // BUDGET & DÉPENSES
  // ============================================================================

  /// Récupérer les lignes budgétaires d'un projet
  Future<List<BudgetLigne>> getBudgetLignesByProject(int projetId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.budgetLignes,
        where: 'projet_id = ?',
        whereArgs: [projetId],
        orderBy: 'code_ligne ASC',
      );
      return maps.map((map) => BudgetLigne.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching budget lines: $e');
      return [];
    }
  }

  /// Créer une ligne budgétaire
  Future<int> createBudgetLigne(BudgetLigne ligne) async {
    try {
      final db = await _db.database;
      return await db.insert(DatabaseTables.budgetLignes, ligne.toMap());
    } catch (e) {
      debugPrint('❌ Error creating budget line: $e');
      rethrow;
    }
  }

  /// Récupérer les dépenses d'un projet
  Future<List<Depense>> getDepensesByProject(int projetId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.depensesDecaissements,
        where: 'projet_id = ?',
        whereArgs: [projetId],
        orderBy: 'date_operation DESC',
      );
      return maps.map((map) => Depense.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching expenses: $e');
      return [];
    }
  }

  /// Créer une dépense
  Future<int> createDepense(Depense depense) async {
    try {
      final db = await _db.database;
      return await db.insert(
        DatabaseTables.depensesDecaissements,
        depense.toMap(),
      );
    } catch (e) {
      debugPrint('❌ Error creating expense: $e');
      rethrow;
    }
  }

  /// Calculer la consommation budgétaire par ligne
  Future<Map<int, double>> getBudgetConsumptionByLine(int projetId) async {
    try {
      final db = await _db.database;
      final results = await db.rawQuery(
        '''
        SELECT budget_ligne_id, SUM(montant) as total_consomme
        FROM ${DatabaseTables.depensesDecaissements}
        WHERE projet_id = ? AND statut_validation != 'rejete'
        GROUP BY budget_ligne_id
      ''',
        [projetId],
      );

      final consumptionMap = <int, double>{};
      for (final row in results) {
        final id = row['budget_ligne_id'] as int;
        final total = (row['total_consomme'] as num).toDouble();
        consumptionMap[id] = total;
      }
      return consumptionMap;
    } catch (e) {
      debugPrint('❌ Error calculating budget consumption: $e');
      return {};
    }
  }
}

// ============================================================================
// CLASSES DE STATISTIQUES
// ============================================================================

/// Statistiques d'un projet
class ProjectStats {
  final int nombreIndicateurs;
  final int nombreIndicateursAtteints;
  final int nombreActivites;
  final double budgetTotal;
  final double budgetExecute;
  final int nombreRisques;
  final int nombreRisquesCritiques;
  final int nombreBeneficiaires;
  final int nombreBeneficiairesAtteints;

  const ProjectStats({
    required this.nombreIndicateurs,
    required this.nombreIndicateursAtteints,
    required this.nombreActivites,
    required this.budgetTotal,
    required this.budgetExecute,
    required this.nombreRisques,
    required this.nombreRisquesCritiques,
    required this.nombreBeneficiaires,
    required this.nombreBeneficiairesAtteints,
  });

  double get tauxExecutionBudget {
    if (budgetTotal == 0) return 0.0;
    return (budgetExecute / budgetTotal * 100).clamp(0.0, 100.0);
  }
}

/// Statistiques du dashboard principal
class DashboardStats {
  final int totalProjects;
  final int activeProjects;
  final double budgetTotal;
  final double budgetExecute;
  final int totalBeneficiaires;
  final double tauxIndicateurs;
  final int nombreBailleurs;
  final int nombreUtilisateurs;

  const DashboardStats({
    required this.totalProjects,
    required this.activeProjects,
    required this.budgetTotal,
    required this.budgetExecute,
    required this.totalBeneficiaires,
    required this.tauxIndicateurs,
    required this.nombreBailleurs,
    required this.nombreUtilisateurs,
  });
}

/// Statistiques des activités
class ActiviteStats {
  final int total;
  final int terminees;
  final int enCours;
  final int enRetard;
  final double avancementMoyen;
  final double budgetTotal;
  final double budgetRealise;

  const ActiviteStats({
    required this.total,
    required this.terminees,
    required this.enCours,
    required this.enRetard,
    required this.avancementMoyen,
    required this.budgetTotal,
    required this.budgetRealise,
  });

  double get tauxAchievement {
    if (total == 0) return 0.0;
    return (terminees / total * 100);
  }

  double get tauxExecutionBudget {
    if (budgetTotal == 0) return 0.0;
    return (budgetRealise / budgetTotal * 100);
  }
}
