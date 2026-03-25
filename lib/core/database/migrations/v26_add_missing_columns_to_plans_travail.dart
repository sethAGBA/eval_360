import 'package:sqflite/sqflite.dart';
import '../database_tables.dart';

class V26AddMissingColumnsToPlansTravail {
  static Future<void> migrate(Database db) async {
    try {
      // Vérifier les colonnes existantes
      final result = await db.rawQuery('PRAGMA table_info(${DatabaseTables.plansTravail})');
      final columnNames = result.map((row) => row['name'] as String).toList();

      final columnsToAdd = [
        PlansTravailColumns.trimestre,
        PlansTravailColumns.mois,
        PlansTravailColumns.dateDebut,
        PlansTravailColumns.dateFin,
        PlansTravailColumns.valideParId,
        PlansTravailColumns.dateValidation,
      ];

      for (var columnName in columnsToAdd) {
        if (!columnNames.contains(columnName)) {
          String columnDef;
          switch (columnName) {
            case PlansTravailColumns.trimestre:
              columnDef = '$columnName INTEGER';
              break;
            case PlansTravailColumns.mois:
              columnDef = '$columnName INTEGER';
              break;
            case PlansTravailColumns.dateDebut:
              columnDef = '$columnName TEXT NOT NULL DEFAULT ""';
              break;
            case PlansTravailColumns.dateFin:
              columnDef = '$columnName TEXT NOT NULL DEFAULT ""';
              break;
            case PlansTravailColumns.valideParId:
              columnDef = '$columnName INTEGER';
              break;
            case PlansTravailColumns.dateValidation:
              columnDef = '$columnName TEXT';
              break;
            default:
              continue;
          }

          await db.execute('ALTER TABLE ${DatabaseTables.plansTravail} ADD COLUMN $columnDef');
          print('✅ Added $columnName column to plans_travail table');
        } else {
          print('ℹ️ $columnName column already exists in plans_travail table');
        }
      }

      // Mettre à jour les enregistrements existants avec des dates par défaut
      await db.execute('''
        UPDATE ${DatabaseTables.plansTravail}
        SET ${PlansTravailColumns.dateDebut} = ${PlansTravailColumns.annee} || '-01-01T00:00:00.000',
            ${PlansTravailColumns.dateFin} = ${PlansTravailColumns.annee} || '-12-31T23:59:59.999'
        WHERE ${PlansTravailColumns.dateDebut} IS NULL OR ${PlansTravailColumns.dateDebut} = ''
      ''');

    } catch (e) {
      print('Error migrating plans_travail table: $e');
      rethrow;
    }
  }
}