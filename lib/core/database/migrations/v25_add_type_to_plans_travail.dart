import 'package:sqflite/sqflite.dart';
import '../database_tables.dart';

class V25AddTypeToPlansTravail {
  static Future<void> migrate(Database db) async {
    try {
      // Vérifier si la colonne 'type' existe déjà
      final result = await db.rawQuery('PRAGMA table_info(${DatabaseTables.plansTravail})');
      final columnNames = result.map((row) => row['name'] as String).toList();

      if (!columnNames.contains(PlansTravailColumns.type)) {
        // Ajouter la colonne 'type' seulement si elle n'existe pas
        await db.execute('''
          ALTER TABLE ${DatabaseTables.plansTravail}
          ADD COLUMN ${PlansTravailColumns.type} TEXT NOT NULL DEFAULT 'annuel'
        ''');
        print('✅ Added type column to plans_travail table');
      } else {
        print('ℹ️ type column already exists in plans_travail table');
      }
    } catch (e) {
      // Ignorer si la colonne existe déjà (cas de migration répétée)
      print('Note: type column might already exist in plans_travail table: $e');
    }
  }
}
