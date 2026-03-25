import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/activite.dart';
import '../../../../core/services/database_service.dart';

final activitesProvider = FutureProvider<List<Activite>>((ref) async {
  return await DatabaseService.instance.getActivites();
});
