import 'dart:convert';
import 'dart:io';

import 'package:dart_api/users_ui.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dart_api/db.dart';

Future<Response> getUsersHandler(Request request) async {
  final users = await Db.query('SELECT id, name FROM users');
  return Response.ok(jsonEncode(users), headers: {
    'Content-Type': 'application/json',
  });
}

Future<void> main() async {
  await Db.init();

  final router = Router()
    ..get('/', (req) => Response.ok('API is running'))
    ..get('/users', getUsersHandler)
    ..mount('/', usersUiRouter().call);

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('API running on http://localhost:${server.port}');
}
