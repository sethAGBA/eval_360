import 'package:sqflite/sqflite.dart';

/// Migration V15 - Renforcement du suivi des PDC
/// Ajoute des colonnes détaillées pour le Plan de Développement Communal
class V15ReinforcedCommunes {
  static Future<void> migrate(Database db) async {
    await db.execute('ALTER TABLE communes_pdc ADD COLUMN pdc_periode_debut INTEGER');
    await db.execute('ALTER TABLE communes_pdc ADD COLUMN pdc_periode_fin INTEGER');
    await db.execute('ALTER TABLE communes_pdc ADD COLUMN pdc_document_url TEXT');
    await db.execute('ALTER TABLE communes_pdc ADD COLUMN contact_email TEXT');
    await db.execute('ALTER TABLE communes_pdc ADD COLUMN contact_telephone TEXT');
    await db.execute('ALTER TABLE communes_pdc ADD COLUMN description TEXT');
    await db.execute('ALTER TABLE communes_pdc ADD COLUMN nb_habitants INTEGER');
    
    print('V15 Reinforced Communes migration completed');
  }
}
