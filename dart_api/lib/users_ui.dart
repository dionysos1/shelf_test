import 'dart:convert';
import 'package:dart_api/db.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router usersUiRouter() {
  final router = Router();

  router.get('/users-ui', _serveHtml);
  router.get('/api/users', _getUsers);
  router.post('/api/users', _addUser);
  router.put('/api/users', _updateUser);
  router.delete('/api/users', _deleteUser);

  return router;
}

Future<Response> _getUsers(Request request) async {
  final users = await Db.query('SELECT id, name FROM users ORDER BY id');
  return Response.ok(jsonEncode(users), headers: {
    'Content-Type': 'application/json',
  });
}

Future<Response> _addUser(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);
  final name = (data['name'] ?? '').toString().trim();

  if (name.isEmpty) return Response.badRequest(body: 'Name required');

  await Db.raw.execute(
    Sql.named('INSERT INTO users (name) VALUES (@name)'),
    parameters: {'name': name},
  );
  return Response.ok('OK');
}

Future<Response> _updateUser(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);
  final id = data['id'];
  final name = (data['name'] ?? '').toString().trim();

  if (id == null || name.isEmpty) return Response.badRequest(body: 'Invalid data');

  await Db.raw.execute(
    Sql.named('UPDATE users SET name = @name WHERE id = @id'),
    parameters: {'id': id, 'name': name},
  );
  return Response.ok('OK');
}

Future<Response> _deleteUser(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);
  final id = data['id'];

  if (id == null) return Response.badRequest(body: 'Missing id');

  await Db.raw.execute(
    Sql.named('DELETE FROM users WHERE id = @id'),
    parameters: {'id': id},
  );
  return Response.ok('OK');
}


Response _serveHtml(Request request) {
  const html = '''
<!DOCTYPE html>
<html>
<head>
  <title>Users CRUD</title>
  <link href="https://unpkg.com/tabulator-tables@5.6.1/dist/css/tabulator.min.css" rel="stylesheet">
  <script src="https://unpkg.com/tabulator-tables@5.6.1/dist/js/tabulator.min.js"></script>
</head>
<body>
  <h2>Users</h2>
  <div id="user-table"></div>

  <script>
    const table = new Tabulator("#user-table", {
      layout: "fitColumns",
      ajaxURL: "/api/users",
      ajaxConfig: "GET",
      columns: [
        { title: "ID", field: "id", width: 50, editor: false },
        { title: "Name", field: "name", editor: "input" },
        {
          title: "Actions",
          formatter: () => "<button>❌</button>",
          width: 70,
          cellClick: function(e, cell) {
            const data = cell.getRow().getData();
            fetch("/api/users", {
              method: "DELETE",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({ id: data.id }),
            }).then(() => table.replaceData());
          }
        },
      ],
      cellEdited: function(cell) {
        const data = cell.getRow().getData();
        fetch("/api/users", {
          method: "PUT",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(data),
        });
      }
    });

    const addBtn = document.createElement("button");
    addBtn.textContent = "➕ Add User";
    addBtn.onclick = () => {
      const name = prompt("Enter new user name:");
      if (name) {
        fetch("/api/users", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ name }),
        }).then(() => table.replaceData());
      }
    };
    document.body.insertBefore(addBtn, document.getElementById("user-table"));
  </script>
</body>
</html>
''';
  return Response.ok(html, headers: {'Content-Type': 'text/html'});
}