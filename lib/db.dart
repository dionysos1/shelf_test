import 'dart:io';
import 'package:postgres/postgres.dart';

class Db {
  static late final Connection _connection;

  /// Initialize the database connection (called once on startup)
  static Future<void> init() async {
    _connection = await Connection.open(
      Endpoint(
        host: Platform.environment['DB_HOST'] ?? 'localhost',
        port: int.parse(Platform.environment['DB_PORT'] ?? '5432'),
        database: Platform.environment['DB_NAME'] ?? 'mydb',
        username: Platform.environment['DB_USER'] ?? 'myuser',
        password: Platform.environment['DB_PASS'] ?? 'mypass',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  /// Run a simple SELECT query and return rows as a list of maps
  static Future<List<Map<String, dynamic>>> query(String sql) async {
    final result = await _connection.execute(Sql.named(sql));

    // Get column names from schema
    final columnNames = result.schema.columns
        .map((col) => col.columnName ?? '') // fallback to empty if null
        .toList();

    return result.map((row) {
      final rowMap = <String, dynamic>{};
      for (var i = 0; i < columnNames.length; i++) {
        final colName = columnNames[i];
        if (colName.isNotEmpty) {
          rowMap[colName] = row[i];
        }
      }
      return rowMap;
    }).toList();
  }

  /// Allow raw access if needed
  static Connection get raw => _connection;
}
