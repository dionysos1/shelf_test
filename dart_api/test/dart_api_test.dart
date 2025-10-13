import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:http/http.dart' as http;

import 'package:dart_api/db.dart';
import 'package:dart_api/users_ui.dart';

void main() {
  late HttpServer server;
  late Uri baseUrl;

  setUpAll(() async {
    await Db.init();

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(usersUiRouter());

    server = await io.serve(handler, 'localhost', 0);
    baseUrl = Uri.parse('http://localhost:${server.port}');
  });

  tearDownAll(() async {
    await server.close(force: true);
  });

  test('GET /api/users returns a list', () async {
    final response = await http.get(baseUrl.resolve('/api/users'));

    expect(response.statusCode, equals(200));

    final body = jsonDecode(response.body);
    expect(body, isA<List>());
  });

  test('POST /api/users creates a user', () async {
    final name = 'TestUser_${DateTime.now().millisecondsSinceEpoch}';

    final response = await http.post(
      baseUrl.resolve('/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    expect(response.statusCode, equals(200));

    final users = await Db.query("SELECT * FROM users WHERE name = '$name'");
    expect(users.any((u) => u['name'] == name), isTrue);
  });
}
