import 'package:phony/databases/database.dart';
import 'package:phony/repositories/maintenance_repository.dart';

class DriftMaintenanceRepository implements MaintenanceRepository {
  final AppDatabase _db;

  DriftMaintenanceRepository(this._db);

  @override
  Future<void> resetLibrary() => _db.resetDatabase();
}
