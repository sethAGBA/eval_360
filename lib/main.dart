import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/database/database_helper.dart';

void main() async {
  // Initialiser Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le support de la localisation pour les dates (fr_FR)
  await initializeDateFormatting('fr_FR', null);

  // Initialiser sqflite_ffi pour desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialiser la base de données
  try {
    await DatabaseHelper.instance.database;
    debugPrint('✅ Database initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing database: $e');
  }

  // Lancer l'application
  runApp(const ProviderScope(child: Eval360App()));
}
