import 'package:sqflite/sqflite.dart';

/// Migration V12 - Ajout du matricule pour les Utilisateurs
class V12UserMatriculeSchema {
  static Future<void> migrate(Database db) async {
    // SQLite ne supporte pas l'ajout de colonnes avec contraintes NOT NULL sans valeur par défaut
    // On ajoute la colonne matricule
    await db.execute('ALTER TABLE utilisateurs_acces ADD COLUMN matricule TEXT');
    
    // On pourrait générer des matricules par défaut pour les utilisateurs existants
    // EX: MAT-ID
    await db.execute("UPDATE utilisateurs_acces SET matricule = 'MAT-' || id WHERE matricule IS NULL");
    
    print('V12 User Matricule Schema migration completed');
  }
}
