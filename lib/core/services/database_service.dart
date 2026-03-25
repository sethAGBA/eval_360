import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/app_config.dart';
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
import '../models/rapport_hebdo.dart';
import '../models/document.dart';
import '../models/tdr.dart';
import '../models/ordre_mission.dart';
import '../models/rapport_stage.dart';
import '../models/commune.dart';
import '../models/partenaire.dart';
import '../models/ligne_rapport.dart';
import '../models/rapport_mensuel.dart';
import '../models/synthese_axe.dart';
import '../models/tache.dart';
import '../models/plan_travail.dart';
import '../models/livrable.dart';
import '../database/migrations/v5_monthly_reports_schema.dart';

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

  /// Lier un partenaire (PTF) à un projet
  Future<void> linkPartenaireToProject({
    required int projetId,
    required int partenaireId,
    String? role,
  }) async {
    try {
      await _db.insert(DatabaseTables.projetPartenaires, {
        'projet_id': projetId,
        'partenaire_id': partenaireId,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Error linking partenaire to project: $e');
      rethrow;
    }
  }

  /// Récupérer les partenaires (PTF) d'un projet
  Future<List<Partenaire>> getPartenairesByProject(int projetId) async {
    try {
      final sql =
          '''
        SELECT pt.* FROM ${DatabaseTables.partenaniresPtf} pt
        INNER JOIN ${DatabaseTables.projetPartenaires} pp ON pt.id = pp.partenaire_id
        WHERE pp.projet_id = ?
      ''';

      final results = await _db.rawQuery(sql, [projetId]);
      return results.map((map) => Partenaire.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting partenaires by project: $e');
      rethrow;
    }
  }

  /// Mettre à jour les partenaires (PTF) d'un projet
  Future<void> updateProjectPartenaires(
    int projectId,
    List<int> partenaireIds,
  ) async {
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        // 1. Supprimer les liens existants
        await txn.delete(
          DatabaseTables.projetPartenaires,
          where: 'projet_id = ?',
          whereArgs: [projectId],
        );

        // 2. Ajouter les nouveaux liens
        final now = DateTime.now().toIso8601String();
        for (final partenaireId in partenaireIds) {
          await txn.insert(DatabaseTables.projetPartenaires, {
            'projet_id': projectId,
            'partenaire_id': partenaireId,
            'role': 'Partenaire technique',
            'created_at': now,
          });
        }
      });
    } catch (e) {
      debugPrint('❌ Error updating project partenaires: $e');
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
    int? communeId,
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

      if (communeId != null) {
        sql += ' AND ${ZonesColumns.communeId} = ?';
        args.add(communeId);
      }

      sql += ' ORDER BY ${ZonesColumns.pays}, ${ZonesColumns.region}, ${ZonesColumns.villageQuartier} ASC';

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
      final sql = '''
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

  /// Récupérer les zones d'une commune
  Future<List<ZoneIntervention>> getZonesByCommune(int communeId) async {
    return await getZones(communeId: communeId);
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

  /// Supprimer un élément du cadre logique
  Future<void> deleteCadreLogique(int id) async {
    try {
      final db = await _db.database;
      await db.delete(
        DatabaseTables.cadreLogique,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('❌ Error deleting cadre logique: $e');
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

  /// Récupérer une activité par son ID
  Future<Activite?> getActiviteById(int id) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.activites,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return await _enrichActivite(db, maps.first);
    } catch (e) {
      debugPrint('❌ Error fetching activity by ID: $e');
      return null;
    }
  }

  /// Récupérer toutes les activités avec leurs agents
  Future<List<Activite>> getActivites() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.activites,
      );

      List<Activite> activites = [];
      for (var map in maps) {
        activites.add(await _enrichActivite(db, map));
      }
      return activites;
    } catch (e) {
      debugPrint('❌ Error fetching all activities: $e');
      return [];
    }
  }

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
      final db = await _db.database;
      List<Activite> activites = [];
      for (var map in results) {
        activites.add(await _enrichActivite(db, map));
      }
      return activites;
    } catch (e) {
      debugPrint('❌ Error getting activites: $e');
      rethrow;
    }
  }

  /// Récupérer les activités d'un Plan de Travail Annuel (PTBA)
  Future<List<Activite>> getActivitesByPlanTravail(int planTravailId) async {
    try {
      final db = await _db.database;
      final results = await db.query(
        DatabaseTables.activites,
        where: 'plan_travail_id = ?',
        whereArgs: [planTravailId],
        orderBy: 'date_debut_prevue ASC',
      );

      List<Activite> activites = [];
      for (var map in results) {
        activites.add(await _enrichActivite(db, map));
      }
      return activites;
    } catch (e) {
      debugPrint('❌ Error fetch activities by PTBA: $e');
      throw Exception('Erreur lors de la récupération des activités du PTBA');
    }
  }

  /// Créer une activité
  Future<int> createActivite(Activite activite) async {
    try {
      final db = await _db.database;
      return await db.transaction((txn) async {
        final activiteId = await txn.insert(
          DatabaseTables.activites,
          activite.toMap(),
        );

        // Assignations des agents
        for (final agentId in activite.agentIds) {
          await txn.insert(
            DatabaseTables.activiteAssignations,
            {'activite_id': activiteId, 'agent_id': agentId},
          );
        }

        // Association des communes (Multi-Communes)
        for (final communeId in activite.communeIds) {
          await txn.insert(
            DatabaseTables.activiteCommunes,
            {'activite_id': activiteId, 'commune_id': communeId},
          );
        }

        // Association des éléments du cadre logique (Multi-Cadre Logique)
        for (final cadreId in activite.cadreLogiqueIds) {
          await txn.insert(
            DatabaseTables.activiteCadreLogique,
            {'activite_id': activiteId, 'cadre_logique_id': cadreId},
          );
        }

        // Association des zones (Multi-Zones)
        for (final zoneId in activite.zoneIds) {
          await txn.insert(
            DatabaseTables.activiteZones,
            {'activite_id': activiteId, 'zone_id': zoneId},
          );
        }

        return activiteId;
      });
    } catch (e) {
      debugPrint('❌ Error creating activite: $e');
      rethrow;
    }
  }

  /// Mettre à jour une activité
  Future<void> updateActivite(Activite activite) async {
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        await txn.update(
          DatabaseTables.activites,
          activite.toMap(),
          where: 'id = ?',
          whereArgs: [activite.id],
        );

        // Mettre à jour les agents
        await txn.delete(
          DatabaseTables.activiteAssignations,
          where: 'activite_id = ?',
          whereArgs: [activite.id],
        );
        for (final agentId in activite.agentIds) {
          await txn.insert(
            DatabaseTables.activiteAssignations,
            {'activite_id': activite.id, 'agent_id': agentId},
          );
        }

        // Mettre à jour les communes (Multi-Communes)
        await txn.delete(
          DatabaseTables.activiteCommunes,
          where: 'activite_id = ?',
          whereArgs: [activite.id],
        );
        for (final communeId in activite.communeIds) {
          await txn.insert(
            DatabaseTables.activiteCommunes,
            {'activite_id': activite.id, 'commune_id': communeId},
          );
        }

        // Mettre à jour les cadres logiques (Multi-Cadre Logique)
        await txn.delete(
          DatabaseTables.activiteCadreLogique,
          where: 'activite_id = ?',
          whereArgs: [activite.id],
        );
        for (final cadreId in activite.cadreLogiqueIds) {
          await txn.insert(
            DatabaseTables.activiteCadreLogique,
            {'activite_id': activite.id, 'cadre_logique_id': cadreId},
          );
        }

        // Mettre à jour les zones (Multi-Zones)
        await txn.delete(
          DatabaseTables.activiteZones,
          where: 'activite_id = ?',
          whereArgs: [activite.id],
        );
        for (final zoneId in activite.zoneIds) {
          await txn.insert(
            DatabaseTables.activiteZones,
            {'activite_id': activite.id, 'zone_id': zoneId},
          );
        }
      });
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

  /// Enrichir une activité avec ses associations (agents, communes)
  Future<Activite> _enrichActivite(Database db, Map<String, dynamic> row) async {
    final activiteId = row['id'] as int;

    // Récupérer les agents assignés
    final agentsRaw = await db.query(
      DatabaseTables.activiteAssignations,
      where: 'activite_id = ?',
      whereArgs: [activiteId],
    );
    final agentIds = agentsRaw.map((a) => a['agent_id'] as int).toList();

    // Récupérer les communes liées
    final communesRaw = await db.query(
      DatabaseTables.activiteCommunes,
      where: 'activite_id = ?',
      whereArgs: [activiteId],
    );
    final communeIds = communesRaw.map((c) => c['commune_id'] as int).toList();

    // Récupérer les cadres logiques liés
    final cadresRaw = await db.query(
      DatabaseTables.activiteCadreLogique,
      where: 'activite_id = ?',
      whereArgs: [activiteId],
    );
    final cadreIds = cadresRaw.map((c) => c['cadre_logique_id'] as int).toList();

    // Récupérer les zones liées
    final zonesRaw = await db.query(
      DatabaseTables.activiteZones,
      where: 'activite_id = ?',
      whereArgs: [activiteId],
    );
    final zoneIds = zonesRaw.map((z) => z['zone_id'] as int).toList();

    return Activite.fromMap({
      ...row,
      'agent_ids': agentIds,
      'commune_ids': communeIds,
      'cadre_logique_ids': cadreIds,
      'zone_ids': zoneIds,
    });
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

  /// Récupérer les statistiques budgétaires globales
  Future<Map<String, double>> getGlobalBudgetStats() async {
    try {
      final db = await _db.database;

      // Budget Total (Somme des budgets révisés de toutes les lignes)
      final budgetTotalResult = await db.rawQuery(
        'SELECT SUM(budget_revise) as total FROM ${DatabaseTables.budgetLignes}',
      );
      final double budgetTotal =
          (budgetTotalResult.first['total'] as num? ?? 0.0).toDouble();

      // Dépenses Totales (Somme des dépenses non rejetées)
      final depensesTotalResult = await db.rawQuery(
        "SELECT SUM(montant) as total FROM ${DatabaseTables.depensesDecaissements} WHERE statut_validation != 'rejete'",
      );
      final double depensesTotal =
          (depensesTotalResult.first['total'] as num? ?? 0.0).toDouble();

      return {
        'budgetTotal': budgetTotal,
        'depensesTotal': depensesTotal,
        'solde': budgetTotal - depensesTotal,
      };
    } catch (e) {
      debugPrint('❌ Error fetching global budget stats: $e');
      return {'budgetTotal': 0.0, 'depensesTotal': 0.0, 'solde': 0.0};
    }
  }

  /// Mettre à jour le statut d'une dépense
  Future<void> updateDepenseStatus(
    int depenseId,
    StatutValidationDepense status,
  ) async {
    try {
      final db = await _db.database;
      await db.update(
        DatabaseTables.depensesDecaissements,
        {'statut_validation': status.name},
        where: 'id = ?',
        whereArgs: [depenseId],
      );
    } catch (e) {
      debugPrint('❌ Error updating expense status: $e');
      rethrow;
    }
  }

  /// Récupérer toutes les dépenses (tous projets confondus)
  Future<List<Depense>> getAllDepenses() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.depensesDecaissements,
        orderBy: 'date_operation DESC',
      );
      return maps.map((map) => Depense.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching all expenses: $e');
      return [];
    }
  }

  // ============================================================================
  // DIGITALISATION & GED (Phase 3)
  // ============================================================================

  /// Récupérer les documents (filtrage optionnel par projet)
  Future<List<Document>> getDocuments({
    int? projetId,
    TypeDocument? type,
  }) async {
    try {
      final db = await _db.database;
      String where = '';
      List<dynamic> whereArgs = [];

      if (projetId != null) {
        where = 'projet_id = ?';
        whereArgs.add(projetId);
      }

      if (type != null) {
        if (where.isNotEmpty) where += ' AND ';
        where += 'type_document = ?';
        whereArgs.add(type.name);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.documents,
        where: where.isNotEmpty ? where : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date_document DESC',
      );
      return maps.map((map) => Document.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching documents: $e');
      return [];
    }
  }

  /// Créer un document générique
  Future<int> createDocument(Document doc) async {
    try {
      final db = await _db.database;
      return await db.insert(DatabaseTables.documents, doc.toMap());
    } catch (e) {
      debugPrint('❌ Error creating document: $e');
      rethrow;
    }
  }

  /// Créer un TdR rattaché à un document
  Future<int> createTdR(TdR tdr) async {
    try {
      final db = await _db.database;
      return await db.insert(DatabaseTables.termesDeReference, tdr.toMap());
    } catch (e) {
      debugPrint('❌ Error creating TdR: $e');
      rethrow;
    }
  }

  /// Récupérer le TdR rattaché à un document
  Future<TdR?> getTdRByDocumentId(int docId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.termesDeReference,
        where: 'document_id = ?',
        whereArgs: [docId],
      );
      if (maps.isEmpty) return null;
      return TdR.fromMap(maps.first);
    } catch (e) {
      debugPrint('❌ Error fetching TdR: $e');
      return null;
    }
  }

  /// Créer un Ordre de Mission
  Future<int> createOrdreMission(OrdreMission ord) async {
    try {
      final db = await _db.database;
      return await db.insert(DatabaseTables.ordresMission, ord.toMap());
    } catch (e) {
      debugPrint('❌ Error creating OrdreMission: $e');
      rethrow;
    }
  }

  /// Récupérer l'Ordre de Mission rattaché à un document
  Future<OrdreMission?> getOrdreMissionByDocumentId(int docId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.ordresMission,
        where: 'document_id = ?',
        whereArgs: [docId],
      );
      if (maps.isEmpty) return null;
      return OrdreMission.fromMap(maps.first);
    } catch (e) {
      debugPrint('❌ Error fetching OrdreMission: $e');
      return null;
    }
  }

  /// Créer un Rapport de Stage
  Future<int> createRapportStage(RapportStage rapp) async {
    try {
      final db = await _db.database;
      return await db.insert(DatabaseTables.rapportsStage, rapp.toMap());
    } catch (e) {
      debugPrint('❌ Error creating RapportStage: $e');
      rethrow;
    }
  }

  /// Récupérer le Rapport de Stage rattaché à un document
  Future<RapportStage?> getRapportStageByDocumentId(int docId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.rapportsStage,
        where: 'document_id = ?',
        whereArgs: [docId],
      );
      if (maps.isEmpty) return null;
      return RapportStage.fromMap(maps.first);
    } catch (e) {
      debugPrint('❌ Error fetching RapportStage: $e');
      return null;
    }
  }

  // ============================================================================
  // PARTENAIRES PTF (Module 10)
  // ============================================================================

  /// Récupérer tous les partenaires
  Future<List<Partenaire>> getPartenaires({bool? actifSeulement}) async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        DatabaseTables.partenaniresPtf,
        where: actifSeulement == true ? 'actif = 1' : null,
        orderBy: 'nom ASC',
      );
      return maps.map((m) => Partenaire.fromMap(m)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching partenaires: $e');
      return [];
    }
  }

  /// Créer un partenaire
  Future<int> createPartenaire(Partenaire p) async {
    try {
      final db = await _db.database;
      return await db.insert(DatabaseTables.partenaniresPtf, p.toMap());
    } catch (e) {
      debugPrint('❌ Error creating partenaire: $e');
      rethrow;
    }
  }

  /// Mettre à jour un partenaire
  Future<int> updatePartenaire(Partenaire p) async {
    try {
      final db = await _db.database;
      return await db.update(
        DatabaseTables.partenaniresPtf,
        p.toMap(),
        where: 'id = ?',
        whereArgs: [p.id],
      );
    } catch (e) {
      debugPrint('❌ Error updating partenaire: $e');
      rethrow;
    }
  }

  // ============================================================================
  // SUIVI DES COMMUNES (Module 09)
  // ============================================================================

  /// Récupérer toutes les communes
  Future<List<Commune>> getCommunes() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.communesPdc,
        orderBy: 'region ASC, nom ASC',
      );
      return maps.map((map) => Commune.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching communes: $e');
      return [];
    }
  }

  /// Mettre à jour le taux d'avancement d'un PDC
  Future<int> updateCommunePdc(int id, double taux) async {
    try {
      final db = await _db.database;
      return await db.update(
        DatabaseTables.communesPdc,
        {
          'taux_avancement_pdc': taux,
          'date_maj': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('❌ Error updating commune PDC: $e');
      rethrow;
    }
  }

  /// Créer une nouvelle commune
  Future<int> createCommune(Commune commune) async {
    try {
      final db = await _db.database;
      return await db.insert(DatabaseTables.communesPdc, {
        ...commune.toMap(),
        'date_maj': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Error creating commune: $e');
      rethrow;
    }
  }

  /// Mettre à jour intégralement une commune
  Future<int> updateCommune(Commune commune) async {
    try {
      final db = await _db.database;
      return await db.update(
        DatabaseTables.communesPdc,
        {...commune.toMap(), 'date_maj': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [commune.id],
      );
    } catch (e) {
      debugPrint('❌ Error updating commune: $e');
      rethrow;
    }
  }

  /// Supprimer une commune
  Future<int> deleteCommune(int id) async {
    try {
      final db = await _db.database;
      return await db.delete(
        DatabaseTables.communesPdc,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('❌ Error deleting commune: $e');
      rethrow;
    }
  }

  /// Récupérer les activités liées à une commune (via la zone d'intervention)
  Future<List<Activite>> getActivitesByCommune(
    int communeId,
    String communeName,
  ) async {
    try {
      final db = await _db.database;

      // On cherche les activités liées via la table d'association activite_communes
      // ou indirectement via la zone d'intervention (commune_district)
      final sql = '''
        SELECT DISTINCT a.* FROM ${DatabaseTables.activites} a
        LEFT JOIN ${DatabaseTables.activiteCommunes} ac ON a.id = ac.activite_id
        LEFT JOIN ${DatabaseTables.zones} z ON a.zone_id = z.id
        WHERE ac.commune_id = ? 
        OR (a.zone_id IS NOT NULL AND z.commune_district LIKE ?)
      ''';

      final List<Map<String, dynamic>> results =
          await db.rawQuery(sql, [communeId, '%$communeName%']);
      final List<Activite> activites = [];

      for (var map in results) {
        activites.add(await _enrichActivite(db, map));
      }
      return activites;
    } catch (e) {
      debugPrint('❌ Error getting activites by commune: $e');
      return [];
    }
  }

  // ============================================================================
  // RAPPORTS HEBDOMADAIRES (Module 04)
  // ============================================================================

  /// Récupérer les rapports hebdomadaires avec filtres
  Future<List<RapportHebdo>> getWeeklyReports({
    int? agentId,
    StatutValidationRapport? statut,
    int? annee,
  }) async {
    try {
      final db = await _db.database;
      String where = '1=1';
      final List<dynamic> whereArgs = [];

      if (agentId != null) {
        where += ' AND ${RapportsHebdoColumns.agentId} = ?';
        whereArgs.add(agentId);
      }
      if (statut != null) {
        where += ' AND ${RapportsHebdoColumns.statutValidation} = ?';
        whereArgs.add(statut.name);
      }
      if (annee != null) {
        where += ' AND ${RapportsHebdoColumns.annee} = ?';
        whereArgs.add(annee);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.rapportsHebdo,
        where: where,
        whereArgs: whereArgs,
        orderBy:
            '${RapportsHebdoColumns.annee} DESC, ${RapportsHebdoColumns.semaineNumero} DESC',
      );
      return maps.map((map) => RapportHebdo.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching weekly reports: $e');
      return [];
    }
  }

  /// Récupérer un rapport par son ID
  Future<RapportHebdo?> getWeeklyReportById(int id) async {
    try {
      final result = await _db.queryById(DatabaseTables.rapportsHebdo, id);
      return result != null ? RapportHebdo.fromMap(result) : null;
    } catch (e) {
      debugPrint('❌ Error fetching weekly report by id: $e');
      rethrow;
    }
  }

  /// Récupérer les lignes d'un rapport
  Future<List<LigneRapport>> getLignesByRapportId(int rapportId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.lignesRapport,
        where: '${LignesRapportColumns.rapportId} = ?',
        whereArgs: [rapportId],
      );
      return maps.map((map) => LigneRapport.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching report lines: $e');
      rethrow;
    }
  }

  /// Créer un nouveau rapport avec ses lignes (Transaction)
  Future<int> createWeeklyReport(
    RapportHebdo rapport,
    List<LigneRapport> lignes,
  ) async {
    try {
      final db = await _db.database;
      return await db.transaction((txn) async {
        final rapportId = await txn.insert(
          DatabaseTables.rapportsHebdo,
          rapport.toMap(),
        );

        for (final ligne in lignes) {
          await txn.insert(
            DatabaseTables.lignesRapport,
            ligne.copyWith(rapportId: rapportId).toMap(),
          );
        }

        return rapportId;
      });
    } catch (e) {
      debugPrint('❌ Error creating weekly report: $e');
      rethrow;
    }
  }

  /// Mettre à jour un rapport et ses lignes
  Future<void> updateWeeklyReport(
    RapportHebdo rapport,
    List<LigneRapport> lignes,
  ) async {
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        // 1. Mettre à jour l'entête
        await txn.update(
          DatabaseTables.rapportsHebdo,
          rapport.toMap(),
          where: 'id = ?',
          whereArgs: [rapport.id],
        );

        // 2. Supprimer les anciennes lignes
        await txn.delete(
          DatabaseTables.lignesRapport,
          where: '${LignesRapportColumns.rapportId} = ?',
          whereArgs: [rapport.id],
        );

        // 3. Insérer les nouvelles lignes
        for (final ligne in lignes) {
          await txn.insert(
            DatabaseTables.lignesRapport,
            ligne.copyWith(rapportId: rapport.id).toMap(),
          );
        }
      });
    } catch (e) {
      debugPrint('❌ Error updating weekly report: $e');
      rethrow;
    }
  }

  /// Valider ou rejeter un rapport
  Future<void> validateWeeklyReport({
    required int rapportId,
    required int validatorId,
    required StatutValidationRapport statut,
    String? commentaire,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      await _db.execute(
        '''
        UPDATE ${DatabaseTables.rapportsHebdo}
        SET 
          ${RapportsHebdoColumns.statutValidation} = ?,
          ${RapportsHebdoColumns.commentaireSuperviseur} = ?,
          ${RapportsHebdoColumns.valideParId} = ?,
          ${RapportsHebdoColumns.dateValidation} = ?,
          ${RapportsHebdoColumns.updatedAt} = ?
        WHERE id = ?
        ''',
        [statut.name, commentaire, validatorId, now, now, rapportId],
      );
    } catch (e) {
      debugPrint('❌ Error validating weekly report: $e');
      rethrow;
    }
  }

  /// Supprimer un rapport (Cascade delete géré par la DB)
  Future<void> deleteWeeklyReport(int id) async {
    try {
      await _db.delete(DatabaseTables.rapportsHebdo, id);
    } catch (e) {
      debugPrint('❌ Error deleting weekly report: $e');
      rethrow;
    }
  }

  // ============================================================================
  // RAPPORTS MENSUELS (Module 05)
  // ============================================================================

  /// Récupérer les rapports mensuels d'un agent
  Future<List<RapportMensuel>> getMonthlyReports({
    int? agentId,
    int? annee,
  }) async {
    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (agentId != null) {
        whereClause += '${RapportsMensuelsColumns.agentId} = ?';
        whereArgs.add(agentId);
      }

      if (annee != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += '${RapportsMensuelsColumns.annee} = ?';
        whereArgs.add(annee);
      }

      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.rapportsMensuels,
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy:
            '${RapportsMensuelsColumns.annee} DESC, ${RapportsMensuelsColumns.mois} DESC',
      );

      return List.generate(maps.length, (i) => RapportMensuel.fromMap(maps[i]));
    } catch (e) {
      debugPrint('❌ Error fetching monthly reports: $e');
      return [];
    }
  }

  /// Récupérer un rapport mensuel par ID
  Future<RapportMensuel?> getMonthlyReportById(int id) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.rapportsMensuels,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return RapportMensuel.fromMap(maps.first);
    } catch (e) {
      debugPrint('❌ Error fetching monthly report by id: $e');
      return null;
    }
  }

  /// Récupérer les synthèses par axe d'un rapport mensuel
  Future<List<SyntheseAxe>> getSynthesesByRapportId(int rapportId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.syntheseAxesMensuels,
        where: '${SyntheseAxesMensuelsColumns.rapportMensuelId} = ?',
        whereArgs: [rapportId],
      );
      return List.generate(maps.length, (i) => SyntheseAxe.fromMap(maps[i]));
    } catch (e) {
      debugPrint('❌ Error fetching synthese axes: $e');
      return [];
    }
  }

  /// Consolider un rapport mensuel à partir des rapports hebdomadaires
  Future<int> consolidateMonthlyReport(int agentId, int mois, int annee) async {
    final db = await _db.database;
    return await db.transaction((txn) async {
      // 1. Trouver les dates de début et fin du mois
      final dateDebutMois = DateTime(annee, mois, 1);
      final dateFinMois = DateTime(annee, mois + 1, 0);

      // 2. Récupérer les rapports hebdomadaires validés du mois
      final List<Map<String, dynamic>> hebdoMaps = await txn.query(
        DatabaseTables.rapportsHebdo,
        where: '''
          agent_id = ? AND 
          statut_validation = ? AND 
          ((date_debut >= ? AND date_debut <= ?) OR (date_fin >= ? AND date_fin <= ?))
        ''',
        whereArgs: [
          agentId,
          StatutValidationRapport.valide.name,
          dateDebutMois.toIso8601String(),
          dateFinMois.toIso8601String(),
          dateDebutMois.toIso8601String(),
          dateFinMois.toIso8601String(),
        ],
      );

      if (hebdoMaps.isEmpty) {
        throw Exception(
          'Aucun rapport hebdomadaire validé trouvé pour ce mois.',
        );
      }

      final List<int> hebdoIds = hebdoMaps.map((m) => m['id'] as int).toList();

      // 3. Récupérer toutes les lignes de rapport
      final List<Map<String, dynamic>> ligneMaps = await txn.query(
        DatabaseTables.lignesRapport,
        where: 'rapport_id IN (${hebdoIds.join(",")})',
      );

      // 4. Synthèse par AXE (via activities)
      // Pour cet exemple, on simplifie: on groupe par projet ou par output du cadre logique

      for (final l in ligneMaps) {
        // Logique de regroupement...
        // Pour la démo, on utilise l'activité liée
        final actId = l[LignesRapportColumns.activiteId] as int?;
        if (actId != null) {
          // Trouver l'axe parent (simplifié: on prend le projet pour l'instant ou on simule l'axe)
          // Dans une prod réelle, on ferait un JOIN avec activites et cadre_logique
        }
      }

      // 5. Créer l'entête du rapport mensuel
      final rapportId = await txn.insert(
        DatabaseTables.rapportsMensuels,
        RapportMensuel(
          agentId: agentId,
          mois: mois,
          annee: annee,
          tauxRealisationGlobal: 75.0, // Calculé dynamiquement normalement
          statutValidation: StatutValidationRapport.brouillon,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ).toMap(),
      );

      // 6. Créer les synthèses par axe (Exemple statique pour l'instant)
      await txn.insert(
        DatabaseTables.syntheseAxesMensuels,
        SyntheseAxe(
          rapportMensuelId: rapportId,
          libelleAxe: 'Infrastructures et Équipements',
          tauxRealisation: 80.0,
          nombreActivitesPrevues: 10,
          nombreActivitesRealisees: 8,
        ).toMap(),
      );

      await txn.insert(
        DatabaseTables.syntheseAxesMensuels,
        SyntheseAxe(
          rapportMensuelId: rapportId,
          libelleAxe: 'Renforcement des Capacités',
          tauxRealisation: 60.0,
          nombreActivitesPrevues: 5,
          nombreActivitesRealisees: 3,
        ).toMap(),
      );

      return rapportId;
    });
  }

  // ============================================================================
  // TACHES (Module 06)
  // ============================================================================

  /// Récupérer les tâches avec filtres optionnels
  Future<List<Tache>> getTasks({int? agentId, TacheStatut? statut}) async {
    try {
      final db = await _db.database;
      String sql = 'SELECT t.* FROM ${DatabaseTables.taches} t';
      List<dynamic> args = [];

      if (agentId != null) {
        sql +=
            ' JOIN ${DatabaseTables.tacheAssignations} ta ON t.id = ta.tache_id WHERE ta.agent_id = ?';
        args.add(agentId);
      }

      if (statut != null) {
        sql += agentId != null ? ' AND t.statut = ?' : ' WHERE t.statut = ?';
        args.add(statut.value);
      }

      sql += ' ORDER BY t.priorite DESC, t.date_echeance ASC';

      final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);

      List<Tache> taches = [];
      for (var map in maps) {
        final tacheId = map['id'] as int;
        final agentsRaw = await db.query(
          DatabaseTables.tacheAssignations,
          where: 'tache_id = ?',
          whereArgs: [tacheId],
        );
        final agentIds = agentsRaw.map((a) => a['agent_id'] as int).toList();
        taches.add(Tache.fromMap({...map, 'agent_ids': agentIds}));
      }

      return taches;
    } catch (e) {
      debugPrint('❌ Error fetching tasks: $e');
      rethrow;
    }
  }

  /// Récupérer une tâche par ID
  Future<Tache?> getTaskById(int id) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.taches,
        where: '${TachesColumns.id} = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;

      final agentIdsRaw = await db.query(
        DatabaseTables.tacheAssignations,
        where: 'tache_id = ?',
        whereArgs: [id],
      );
      final agentIds = agentIdsRaw.map((a) => a['agent_id'] as int).toList();

      return Tache.fromMap({...maps.first, 'agent_ids': agentIds});
    } catch (e) {
      debugPrint('❌ Error fetching task by ID: $e');
      rethrow;
    }
  }

  /// Créer une tâche avec ses assignations
  Future<int> createTask(Tache tache) async {
    try {
      final db = await _db.database;
      return await db.transaction((txn) async {
        final id = await txn.insert(
          DatabaseTables.taches,
          tache.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (final agentId in tache.agentIds) {
          await txn.insert(DatabaseTables.tacheAssignations, {
            'tache_id': id,
            'agent_id': agentId,
          });
        }
        return id;
      });
    } catch (e) {
      debugPrint('❌ Error creating task: $e');
      rethrow;
    }
  }

  /// Mettre à jour une tâche et ses assignations
  Future<int> updateTask(Tache tache) async {
    try {
      final db = await _db.database;
      return await db.transaction((txn) async {
        final count = await txn.update(
          DatabaseTables.taches,
          tache.toMap(),
          where: '${TachesColumns.id} = ?',
          whereArgs: [tache.id],
        );

        // Sync assignations
        await txn.delete(
          DatabaseTables.tacheAssignations,
          where: 'tache_id = ?',
          whereArgs: [tache.id],
        );

        for (final agentId in tache.agentIds) {
          await txn.insert(DatabaseTables.tacheAssignations, {
            'tache_id': tache.id,
            'agent_id': agentId,
          });
        }
        return count;
      });
    } catch (e) {
      debugPrint('❌ Error updating task: $e');
      rethrow;
    }
  }

  /// Supprimer une tâche
  Future<int> deleteTask(int id) async {
    try {
      return await _db.delete(DatabaseTables.taches, id);
    } catch (e) {
      debugPrint('❌ Error deleting task: $e');
      rethrow;
    }
  }

  // --- Gestion des Agents (Module 07) ---

  /// Récupérer la liste des agents (utilisateurs)
  Future<List<Utilisateur>> getAgents() async {
    final List<Map<String, dynamic>> maps = await _db.queryAll(
      DatabaseTables.utilisateurs,
    );
    return maps.map((map) => Utilisateur.fromMap(map)).toList();
  }

  /// Récupérer les statistiques de charge de travail d'un agent
  Future<AgentWorkload> getAgentStats(int agentId) async {
    // Nombre total de tâches via la table de liaison
    final totalTasksRaw = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.tacheAssignations} WHERE agent_id = ?',
      [agentId],
    );
    final totalTasks = totalTasksRaw.first['count'] as int? ?? 0;

    // Tâches par statut via join table
    final statsByStatus = await _db.rawQuery(
      'SELECT t.${TachesColumns.statut}, COUNT(*) as count FROM ${DatabaseTables.taches} t '
      'JOIN ${DatabaseTables.tacheAssignations} ta ON t.id = ta.tache_id '
      'WHERE ta.agent_id = ? GROUP BY t.${TachesColumns.statut}',
      [agentId],
    );

    // Calculer le taux d'avancement moyen via join table
    final avgProgressResults = await _db.rawQuery(
      'SELECT AVG(t.${TachesColumns.pourcentageAvancement}) as avg FROM ${DatabaseTables.taches} t '
      'JOIN ${DatabaseTables.tacheAssignations} ta ON t.id = ta.tache_id '
      'WHERE ta.agent_id = ?',
      [agentId],
    );

    final double avgProgress =
        (avgProgressResults.first['avg'] as num?)?.toDouble() ?? 0.0;

    int aFaire = 0;
    int enCours = 0;
    int termine = 0;
    int suspendu = 0;

    for (var row in statsByStatus) {
      final statut = row[TachesColumns.statut] as String;
      final count = row['count'] as int;
      if (statut == TacheStatut.aFaire.name)
        aFaire = count;
      else if (statut == TacheStatut.enCours.name)
        enCours = count;
      else if (statut == TacheStatut.termine.name)
        termine = count;
      else if (statut == TacheStatut.suspendu.name)
        suspendu = count;
    }

    return AgentWorkload(
      agentId: agentId,
      totalTasks: totalTasks,
      aFaire: aFaire,
      enCours: enCours,
      termine: termine,
      suspendu: suspendu,
      averageProgress: avgProgress,
    );
  }

  // ============================================================================
  // DASHBOARD DYNAMIQUE (EXTENSIONS)
  // ============================================================================

  /// Récupérer les activités prévues pour aujourd'hui
  Future<List<Activite>> getActivitesDuJour() async {
    try {
      final db = await _db.database;
      final now = DateTime.now();
      final todayStr = DateTime(now.year, now.month, now.day).toIso8601String();

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.activites,
        where: 'date_debut_prevue <= ? AND date_fin_prevue >= ?',
        whereArgs: [todayStr, todayStr],
        orderBy: 'date_fin_prevue ASC',
      );

      List<Activite> activites = [];
      for (var map in maps) {
        activites.add(await _enrichActivite(db, map));
      }
      return activites;
    } catch (e) {
      debugPrint('❌ Error fetching today activities: $e');
      return [];
    }
  }

  /// Récupérer le nombre de tâches en attente (À FAIRE)
  Future<int> getPendingTasksCount() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseTables.taches} WHERE ${TachesColumns.statut} = ?',
        [TacheStatut.aFaire.value],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('❌ Error counting pending tasks: $e');
      return 0;
    }
  }

  /// Récupérer les alertes critiques basées sur des critères dynamiques
  Future<List<Map<String, dynamic>>> getDashboardAlerts() async {
    final List<Map<String, dynamic>> alerts = [];
    try {
      final db = await _db.database;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day).toIso8601String();

      // 1. Projets en retard (date fin passée et non terminé)
      final delayedProjects = await db.query(
        DatabaseTables.projets,
        where: 'date_fin_prevue < ? AND statut != ?',
        whereArgs: [today, ProjetStatut.cloture.name],
      );
      for (var p in delayedProjects) {
        alerts.add({
          'title': 'Projet en retard',
          'description': 'Le projet "${p['titre']}" a dépassé sa date de fin.',
          'severity': 'error',
          'type': 'project',
          'id': p['id'],
        });
      }

      // 2. Tâches en retard
      final overdueTasks = await db.query(
        DatabaseTables.taches,
        where: 'date_echeance < ? AND statut != ?',
        whereArgs: [today, TacheStatut.termine.value],
      );
      for (var t in overdueTasks) {
        alerts.add({
          'title': 'Tâche hors délai',
          'description': 'La tâche "${t['titre']}" est en retard.',
          'severity': 'warning',
          'type': 'task',
          'id': t['id'],
        });
      }

      // 3. Alerte budgétaire (consommation > 90%)
      final budgetAlerts = await db.rawQuery('''
        SELECT p.id, p.titre, p.budget_total, SUM(d.montant) as consomme
        FROM ${DatabaseTables.projets} p
        JOIN ${DatabaseTables.depensesDecaissements} d ON p.id = d.projet_id
        GROUP BY p.id
        HAVING (SUM(d.montant) / p.budget_total) > 0.9
      ''');
      for (var b in budgetAlerts) {
        alerts.add({
          'title': 'Alerte Budget',
          'description':
              'Le projet "${b['titre']}" a consommé plus de 90% de son budget.',
          'severity': 'warning',
          'type': 'budget',
          'id': b['id'],
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching dashboard alerts: $e');
    }
    return alerts;
  }

  // ============================================================================
  // CONFIGURATION DE L'APPLICATION (Branding Rapports)
  // ============================================================================

  /// Récupérer la configuration de l'application (en-tête rapports)
  Future<AppConfig> getAppConfig() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.appConfig,
        where: 'id = 1',
      );

      if (maps.isNotEmpty) {
        return AppConfig.fromMap(maps.first);
      }
    } catch (e) {
      debugPrint('❌ Error fetching app config: $e');
    }
    return AppConfig();
  }

  /// Sauvegarder la configuration de l'application
  Future<void> saveAppConfig(AppConfig config) async {
    try {
      final db = await _db.database;
      await db.insert(
        DatabaseTables.appConfig,
        {...config.toMap(), 'id': 1},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ Error saving app config: $e');
      rethrow;
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

// ============================================================================
// PLAN DE TRAVAIL ANNUEL (PTBA)
// ============================================================================

extension PtbaDatabaseService on DatabaseService {
  /// Récupérer les PTBA d'un projet
  Future<List<PlanTravail>> getPlansTravailByProjet(int projetId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.plansTravail,
        where: '${PlansTravailColumns.projetId} = ?',
        whereArgs: [projetId],
        orderBy: '${PlansTravailColumns.annee} DESC',
      );
      return maps.map((map) => PlanTravail.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des PTBA: $e');
      throw Exception('Erreur de lecture des PTBA');
    }
  }

  /// Récupérer tous les PTBA
  Future<List<PlanTravail>> getAllPlansTravail() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.plansTravail,
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => PlanTravail.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération de tous les PTBA: $e');
      throw Exception('Erreur de lecture de tous les PTBA');
    }
  }

  /// Créer un PTBA
  Future<int> createPlanTravail(PlanTravail ptba) async {
    try {
      final db = await _db.database;
      return await db.insert(
        DatabaseTables.plansTravail,
        ptba.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Erreur lors de la création du PTBA: $e');
      throw Exception('Erreur de sauvegarde du PTBA');
    }
  }

  /// Mettre à jour un PTBA
  Future<int> updatePlanTravail(PlanTravail ptba) async {
    try {
      final db = await _db.database;
      return await db.update(
        DatabaseTables.plansTravail,
        ptba.toMap(),
        where: '${PlansTravailColumns.id} = ?',
        whereArgs: [ptba.id],
      );
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du PTBA: $e');
      throw Exception('Erreur de mise à jour du PTBA');
    }
  }

  /// Supprimer un PTBA
  Future<int> deletePlanTravail(int id) async {
    try {
      final db = await _db.database;
      return await db.delete(
        DatabaseTables.plansTravail,
        where: '${PlansTravailColumns.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Erreur lors de la suppression du PTBA: $e');
      throw Exception('Erreur de suppression du PTBA');
    }
  }
}

// ============================================================================
// JALONS & LIVRABLES (PTBA)
// ============================================================================

extension LivrablesDatabaseService on DatabaseService {
  /// Récupérer les livrables d'une activité
  Future<List<Livrable>> getLivrablesByActivite(int activiteId) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.jalonsLivrables,
        where: '${JalonsLivrablesColumns.activiteId} = ?',
        whereArgs: [activiteId],
        orderBy: '${JalonsLivrablesColumns.dateEcheance} ASC',
      );
      return maps.map((map) => Livrable.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des livrables: $e');
      throw Exception('Erreur de lecture des livrables');
    }
  }

  /// Créer un livrable
  Future<int> createLivrable(Livrable livrable) async {
    try {
      final db = await _db.database;
      return await db.insert(
        DatabaseTables.jalonsLivrables,
        livrable.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Erreur lors de la création du livrable: $e');
      throw Exception('Erreur de sauvegarde du livrable');
    }
  }

  /// Mettre à jour un livrable
  Future<int> updateLivrable(Livrable livrable) async {
    try {
      final db = await _db.database;
      return await db.update(
        DatabaseTables.jalonsLivrables,
        livrable.toMap(),
        where: '${JalonsLivrablesColumns.id} = ?',
        whereArgs: [livrable.id],
      );
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du livrable: $e');
      throw Exception('Erreur de mise à jour du livrable');
    }
  }

  /// Supprimer un livrable
  Future<int> deleteLivrable(int id) async {
    try {
      final db = await _db.database;
      return await db.delete(
        DatabaseTables.jalonsLivrables,
        where: '${JalonsLivrablesColumns.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Erreur lors de la suppression du livrable: $e');
      throw Exception('Erreur de suppression du livrable');
    }
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

/// Charge de travail d'un agent (Module 07)
class AgentWorkload {
  final int agentId;
  final int totalTasks;
  final int aFaire;
  final int enCours;
  final int termine;
  final int suspendu;
  final double averageProgress;

  const AgentWorkload({
    required this.agentId,
    required this.totalTasks,
    required this.aFaire,
    required this.enCours,
    required this.termine,
    required this.suspendu,
    required this.averageProgress,
  });

  /// Calcul du score de charge (0-100)
  /// Basé sur le nombre de tâches actives (aFaire=1pt, enCours=2pts)
  double get workloadScore {
    if (totalTasks == 0) return 0.0;
    final score = (aFaire * 1.0 + enCours * 2.5);
    // On normalise arbitrairement : 15 pts = 100% de charge théorique
    return (score / 15.0 * 100).clamp(0.0, 100.0);
  }

  String get workloadLevel {
    final score = workloadScore;
    if (score < 30) return 'Faible';
    if (score < 40) return 'Basse';
    if (score < 70) return 'Optimale';
    return 'Élevée';
  }
}
