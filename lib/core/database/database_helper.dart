import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'migrations/v1_initial_schema.dart';
import 'migrations/v2_project_management_schema.dart';
import 'migrations/v3_schema_fixes.dart';
import 'migrations/v4_weekly_reports_schema.dart';
import 'migrations/v5_monthly_reports_schema.dart';
import 'migrations/v6_tasks_schema.dart';
import 'migrations/v7_digitalization_schema.dart';
import 'migrations/v8_internship_schema.dart';
import 'migrations/v9_communes_schema.dart';
import 'migrations/v10_partenaires_schema.dart';
import 'migrations/v11_projet_partenaires_schema.dart';
import 'migrations/v12_user_matricule_schema.dart';
import 'migrations/v13_user_two_factor_secret_schema.dart';
import 'migrations/v14_enhanced_assignments_schema.dart';
import 'migrations/v15_reinforced_communes.dart';
import 'migrations/v16_link_communes_activites.dart';
import 'migrations/v17_multi_communes_activites.dart';
import 'migrations/v18_add_communes_created_at.dart';
import 'migrations/v19_multi_cadre_logique.dart';
import 'migrations/v20_multi_zones.dart';
import 'migrations/v21_link_zones_to_communes.dart';
import 'migrations/v22_app_config_schema.dart';
import 'migrations/v23_ptba_schema.dart';
import 'migrations/v24_fix_ptba_schema.dart';
import 'migrations/v25_add_type_to_plans_travail.dart';
import 'migrations/v26_add_missing_columns_to_plans_travail.dart';

/// Helper pour gérer la base de données SQLite
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static const String _databaseName = 'eval360.db';
  static const int _databaseVersion = 26;

  // Historique des versions :
  // V18: Ajout de created_at aux communes
  // V19: Ajout de created_at aux projets
  // V20: Migration multi-agents pour les tâches et activités
  // V21: Support multi-zones pour les activités
  // V22: Table app_config pour le branding des rapports

  /// Obtenir l'instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialiser la base de données
  Future<Database> _initDatabase() async {
    // Initialiser sqflite_ffi pour desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Obtenir le chemin de la base de données
    // Sur desktop (macOS/Windows/Linux), utiliser getApplicationSupportDirectory()
    // pour éviter les erreurs d'E/S dans le chemin .dart_tool de sqflite_ffi
    final String dbPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final appSupportDir = await getApplicationSupportDirectory();
      dbPath = appSupportDir.path;
    } else {
      dbPath = await getDatabasesPath();
    }

    // Assurer que le dossier existe avant création/open
    final dbDirectory = Directory(dbPath);
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }

    final path = join(dbPath, _databaseName);
    print('📂 Database path: $path');

    // Ouvrir la base de données
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configurer la base de données (activer les foreign keys)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Créer les tables lors de la première création
  Future<void> _onCreate(Database db, int version) async {
    print('Creating database version $version...');

    // Exécuter TOUTES les migrations dans l'ordre
    await V1InitialSchema.migrate(db);
    await V2ProjectManagementSchema.migrate(db);
    await V3SchemaFixes.migrate(db);
    await V4WeeklyReportsSchema.migrate(db);
    await V5MonthlyReportsSchema.migrate(db);
    await V6TasksSchema.migrate(db);
    await V7DigitalizationSchema.migrate(db);
    await V8InternshipSchema.migrate(db);
    await V9CommunesSchema.migrate(db);
    await V10PartenairesSchema.migrate(db);
    await V11ProjetPartenairesSchema.migrate(db);
    await V12UserMatriculeSchema.migrate(db);
    await V13UserTwoFactorSecretSchema.migrate(db);
    await V14EnhancedAssignmentsSchema.migrate(db);
    await V15ReinforcedCommunes.migrate(db);
    await V16LinkCommunesActivites.migrate(db);
    await V17MultiCommunesActivites.migrate(db);
    await V18AddCommunesCreatedAt.migrate(db);
    await V19MultiCadreLogique.migrate(db);
    await V20MultiZones.migrate(db);
    await V21LinkZonesToCommunes.migrate(db);
    await V22AppConfigSchema.migrate(db);
    await V23PtbaSchema.migrate(db);
    await V24FixPtbaSchema.migrate(db);
    await V25AddTypeToPlansTravail.migrate(db);
    await V26AddMissingColumnsToPlansTravail.migrate(db);

    // Insérer les données de test
    await _insertSeedData(db);

    print('Database created successfully (v$version)!');
  }

  /// Mettre à jour la base de données lors d'une nouvelle version
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion...');

    // Appliquer les migrations selon la version
    if (oldVersion < 2) {
      await V2ProjectManagementSchema.migrate(db);
    }

    if (oldVersion < 3) {
      await V3SchemaFixes.migrate(db);
    }

    if (oldVersion < 4) {
      await V4WeeklyReportsSchema.migrate(db);
    }

    if (oldVersion < 5) {
      await V5MonthlyReportsSchema.migrate(db);
    }

    if (oldVersion < 6) {
      await V6TasksSchema.migrate(db);
    }

    if (oldVersion < 7) {
      await V7DigitalizationSchema.migrate(db);
    }
    if (oldVersion < 8) {
      await V8InternshipSchema.migrate(db);
    }
    if (oldVersion < 9) {
      await V9CommunesSchema.migrate(db);
    }
    if (oldVersion < 10) {
      await V10PartenairesSchema.migrate(db);
    }
    if (oldVersion < 11) {
      await V11ProjetPartenairesSchema.migrate(db);
    }
    if (oldVersion < 12) {
      await V12UserMatriculeSchema.migrate(db);
    }
    if (oldVersion < 13) {
      await V13UserTwoFactorSecretSchema.migrate(db);
    }
    if (oldVersion < 14) {
      await V14EnhancedAssignmentsSchema.migrate(db);
    }
    if (oldVersion < 15) {
      await V15ReinforcedCommunes.migrate(db);
    }
    if (oldVersion < 16) {
      await V16LinkCommunesActivites.migrate(db);
    }
    if (oldVersion < 17) {
      await V17MultiCommunesActivites.migrate(db);
    }
    if (oldVersion < 18) {
      await V18AddCommunesCreatedAt.migrate(db);
    }
    if (oldVersion < 19) {
      await V19MultiCadreLogique.migrate(db);
    }
    if (oldVersion < 20) {
      await V20MultiZones.migrate(db);
    }
    if (oldVersion < 21) {
      await V21LinkZonesToCommunes.migrate(db);
    }
    if (oldVersion < 22) {
      await V22AppConfigSchema.migrate(db);
    }
    if (oldVersion < 23) {
      await V23PtbaSchema.migrate(db);
    }
    if (oldVersion < 24) {
      await V24FixPtbaSchema.migrate(db);
    }
    if (oldVersion < 25) {
      await V25AddTypeToPlansTravail.migrate(db);
    }
    if (oldVersion < 26) {
      await V26AddMissingColumnsToPlansTravail.migrate(db);
    }

    // Les futures migrations seront ajoutées ici
    // if (oldVersion < 3) {
    //   await V3Migration.migrate(db);
    // }
  }

  /// Insérer des données de test
  Future<void> _insertSeedData(Database db) async {
    // Utilisateur admin par défaut
    await db.insert('utilisateurs_acces', {
      'username': 'admin',
      'email': 'admin@eval360.com',
      'password_hash':
          r'$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', // password: admin123
      'nom': 'Admin',
      'prenom': 'Système',
      'role': 'super_admin',
      'projets_assignes': '[]',
      'permissions': '{}',
      'actif': 1,
      'two_factor_enabled': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Paramètres système par défaut
    await db.insert('parametres_systeme', {
      'cle': 'organisation_nom',
      'valeur': '"EVAL360 Organisation"',
      'categorie': 'organisation',
      'description': 'Nom de l\'organisation',
      'modifie_at': DateTime.now().toIso8601String(),
    });

    await db.insert('parametres_systeme', {
      'cle': 'app_version',
      'valeur': '"1.0.0"',
      'categorie': 'systeme',
      'description': 'Version de l\'application',
      'modifie_at': DateTime.now().toIso8601String(),
    });

    print('Seed data inserted successfully!');
  }

  /// Méthodes CRUD génériques

  /// Insérer un enregistrement
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  /// Récupérer tous les enregistrements d'une table
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  /// Récupérer un enregistrement par ID
  Future<Map<String, dynamic>?> queryById(String table, int id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Mettre à jour un enregistrement
  Future<int> update(String table, Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'];
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  /// Supprimer un enregistrement
  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  /// Exécuter une requête personnalisée
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Exécuter une commande SQL
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }

  /// Fermer la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Supprimer la base de données (pour les tests)
  Future<void> deleteDatabase() async {
    final String dbPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final appSupportDir = await getApplicationSupportDirectory();
      dbPath = appSupportDir.path;
    } else {
      dbPath = await getDatabasesPath();
    }
    final path = join(dbPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
