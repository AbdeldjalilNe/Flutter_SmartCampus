import 'package:sqflite/sqflite.dart';
import '../utils/logger.dart';

class LocalDatabaseService {
  LocalDatabaseService(this._database);
  final Database _database;

  Database get database => _database;

  // Generic CRUD operations

  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final id = await _database.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.debug('Inserted into $table: id=$id');
      return id;
    } catch (e) {
      AppLogger.error('Error inserting into $table', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool distinct = false,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final results = await _database.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      AppLogger.debug('Query from $table: ${results.length} rows');
      return results;
    } catch (e) {
      AppLogger.error('Error querying $table', e);
      rethrow;
    }
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final count = await _database.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.debug('Updated $table: $count rows');
      return count;
    } catch (e) {
      AppLogger.error('Error updating $table', e);
      rethrow;
    }
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final count = await _database.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      AppLogger.debug('Deleted from $table: $count rows');
      return count;
    } catch (e) {
      AppLogger.error('Error deleting from $table', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final results = await query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? orderBy,
  }) async =>
      query(table, orderBy: orderBy);

  Future<int> count(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final results = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return results.first['count']! as int;
  }

  // Batch operations
  Future<void> batchInsert(
      String table, List<Map<String, dynamic>> dataList,) async {
    final batch = _database.batch();

    for (final data in dataList) {
      batch.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    AppLogger.debug('Batch inserted ${dataList.length} rows into $table');
  }

  Future<void> batchDelete(String table, List<String> ids) async {
    final batch = _database.batch();

    for (final id in ids) {
      batch.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
    AppLogger.debug('Batch deleted ${ids.length} rows from $table');
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async =>
      _database.transaction(action);

  // Raw queries
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      return await _database.rawQuery(sql, arguments);
    } catch (e) {
      AppLogger.error('Error executing raw query', e);
      rethrow;
    }
  }

  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    try {
      return await _database.rawUpdate(sql, arguments);
    } catch (e) {
      AppLogger.error('Error executing raw update', e);
      rethrow;
    }
  }

  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    try {
      return await _database.rawDelete(sql, arguments);
    } catch (e) {
      AppLogger.error('Error executing raw delete', e);
      rethrow;
    }
  }

  // Table management
  Future<void> clearTable(String table) async {
    await _database.delete(table);
    AppLogger.info('Table $table cleared');
  }

  Future<void> dropTable(String table) async {
    await _database.execute('DROP TABLE IF EXISTS $table');
    AppLogger.info('Table $table dropped');
  }

  Future<bool> tableExists(String table) async {
    final results = await _database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    return results.isNotEmpty;
  }

  // Database maintenance
  Future<void> vacuum() async {
    await _database.execute('VACUUM');
    AppLogger.info('Database vacuumed');
  }

  Future<void> analyze() async {
    await _database.execute('ANALYZE');
    AppLogger.info('Database analyzed');
  }

  Future<void> close() async {
    await _database.close();
    AppLogger.info('Database closed');
  }

  // Cache management
  Future<void> deleteExpiredCache(
      String table, String timestampColumn, Duration maxAge,) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    final deleted = await delete(
      table,
      where: '$timestampColumn < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
    AppLogger.info('Deleted $deleted expired cache entries from $table');
  }

  Future<void> deleteOldRecords(
    String table,
    String timestampColumn,
    int keepCount,
  ) async {
    final totalCount = await count(table);
    if (totalCount <= keepCount) return;

    final toDelete = totalCount - keepCount;
    await _database.execute('''
      DELETE FROM $table 
      WHERE id IN (
        SELECT id FROM $table 
        ORDER BY $timestampColumn ASC 
        LIMIT $toDelete
      )
    ''');
    AppLogger.info('Deleted $toDelete old records from $table');
  }
}
