import 'package:sqflite/sqflite.dart';
import '../database_tables.dart';

class V24FixPtbaSchema {
  static Future<void> migrate(Database db) async {
    final columnsToAdd = [
      '${PlansTravailColumns.budgetTotal} REAL DEFAULT 0.0',
      '${PlansTravailColumns.budgetEtat} REAL DEFAULT 0.0',
      '${PlansTravailColumns.budgetPtf} REAL DEFAULT 0.0',
    ];

    for (var colDef in columnsToAdd) {
      try {
        await db.execute('ALTER TABLE ${DatabaseTables.plansTravail} ADD COLUMN $colDef;');
      } catch (e) {
        // Ignorer si la colonne existe déjà (ce qui serait le cas si V23 avait bien marché complètement)
      }
    }
  }
}
