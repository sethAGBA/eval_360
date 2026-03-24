import 'dart:io';
import 'package:path/path.dart';
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

/// Helper pour gérer la base de données SQLite
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static const String _databaseName = 'eval360.db';
  static const int _databaseVersion = 10;

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

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

    // Exécuter les migrations initiales
    await V1InitialSchema.migrate(db);
    await V2ProjectManagementSchema.migrate(db);
    await V3SchemaFixes.migrate(db);
    await V4WeeklyReportsSchema.migrate(db);
    await V5MonthlyReportsSchema.migrate(db);
    await V6TasksSchema.migrate(db); // Added V6 migration

    // Insérer les données de test
    await _insertSeedData(db);

    print('Database created successfully!');
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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
