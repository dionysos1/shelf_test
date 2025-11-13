import 'dart:io';

import 'package:dart_api/users_ui.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dart_api/db.dart';

Future<void> main() async {
  await Db.init();

  final router = Router()
    ..get('/', (req) => getHomePage)
    ..mount('/', usersUiRouter().call);

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('API running on http://localhost:${server.port}');
}

Response get getHomePage {
  return Response.ok(
    '''
    <html>
      <head><title>Dart API</title></head>
      <body>
        <h2>Available Routes</h2>
        <ul>
          <li><a href="/users-ui">User Management UI</a></li>
          <li><a href="/api/users">Users API (GET)</a></li>
        </ul>
      </body>
    </html>
    ''',
    headers: {'Content-Type': 'text/html'},
  );
}
