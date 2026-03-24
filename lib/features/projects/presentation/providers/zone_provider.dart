// import 'package:eval360/core/models/zone_intervention.dart';
// import 'package:eval360/core/services/database_service.dart';
import 'package:eval_360/core/models/zone_intervention.dart';
import 'package:eval_360/core/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour récupérer toutes les zones d'intervention
final zonesProvider = FutureProvider<List<ZoneIntervention>>((ref) async {
  return await DatabaseService.instance.getZones();
});
