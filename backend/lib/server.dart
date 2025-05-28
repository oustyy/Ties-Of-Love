import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'dart:math';

// Configurações do banco
final db = PostgreSQLConnection(
  'localhost',
  5432,
  'ties_of_love',
  username: 'postgres',
  password: '123',
);

// Função para gerar um código de usuário único
Future<String> _generateUserCode() async {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random rand = Random();
  String code;
  bool isUnique = false;
  int attempts = 0;
  const maxAttempts = 10;

  do {
    code = String.fromCharCodes(
      List.generate(7, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );

    final result = await db.query(
      'SELECT COUNT(*) FROM usuarios WHERE codigo_usuario = @code',
      substitutionValues: {'code': code},
    );

    final count = result[0][0] as int;
    isUnique = count == 0;
    attempts++;
  } while (!isUnique && attempts < maxAttempts);

  if (!isUnique) {
    throw Exception('Não foi possível gerar um código único após $maxAttempts tentativas.');
  }

  return code;
}

void main() async {
  print('Attempting to connect to database...');
  try {
    await db.open();
    print('Database connected successfully!');
  } catch (e) {
    print('Failed to connect to database: $e');
    return;
  }

  try {
    await db.query('''
      CREATE TABLE IF NOT EXISTS usuarios (
        id SERIAL PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        senha TEXT NOT NULL,
        codigo_usuario TEXT UNIQUE NOT NULL,
        codigo_parceiro TEXT,
        status_vinculo TEXT NOT NULL DEFAULT 'livre',
        foto_url TEXT,
        criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    print('Table "usuarios" created or already exists.');
  } catch (e) {
    print('Error creating table: $e');
    return;
  }

  final router = Router();

  // Endpoint de cadastro
  router.post('/cadastrar', (Request request) async {
    try {
      if (db.isClosed) {
        await db.open();
        print('Reopened database connection');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body);

      final nome = data['nome'];
      final email = data['email'];
      final senha = data['senha'];
      final fotoUrl = data['foto_url'] as String? ?? '';

      print('Dados recebidos - nome: $nome, email: $email, foto_url: ${fotoUrl.substring(0, 50)}...'); // Log para verificar

      if (nome == null || email == null || senha == null || nome.isEmpty || email.isEmpty || senha.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Campos nome, email e senha são obrigatórios e não podem estar vazios'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final codigoUsuario = await _generateUserCode();

      final result = await db.query(
        'INSERT INTO usuarios (nome, email, senha, codigo_usuario, status_vinculo, foto_url) VALUES (@nome, @email, @senha, @codigo_usuario, @status_vinculo, @foto_url) RETURNING id',
        substitutionValues: {
          'nome': nome,
          'email': email,
          'senha': senha,
          'codigo_usuario': codigoUsuario,
          'status_vinculo': 'livre',
          'foto_url': fotoUrl,
        },
      );

      if (result.isNotEmpty) {
        print('Usuário inserido com sucesso: ID ${result[0][0]}, foto_url: $fotoUrl');
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Usuário cadastrado com sucesso',
            'codigo_usuario': codigoUsuario,
            'foto_url': fotoUrl,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        print('Falha ao inserir usuário: nenhuma linha afetada');
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Falha ao cadastrar: nenhuma linha afetada'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      print('Erro ao cadastrar: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Erro ao cadastrar: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Endpoint de login
  router.post('/login', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final email = data['email'];
    final senha = data['senha'];

    try {
      final result = await db.query(
        'SELECT * FROM usuarios WHERE email = @email AND senha = @senha',
        substitutionValues: {
          'email': email,
          'senha': senha,
        },
      );

      if (result.isNotEmpty) {
        final user = result.first;
        final userData = {
          'id': user[0],
          'nome': user[1],
          'email': user[2],
          'codigo_usuario': user[4],
          'status_vinculo': user[6],
          'foto_url': user[7],
        };
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Login realizado com sucesso',
            'codigo_usuario': userData['codigo_usuario'],
            'status_vinculo': userData['status_vinculo'],
            'foto_url': userData['foto_url'],
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.forbidden(
          jsonEncode({'success': false, 'message': 'Email ou senha inválidos'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Erro no login: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Endpoint para verificar o código do parceiro
  router.post('/verificar-codigo-parceiro', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userCode = data['user_code'];
      final partnerCode = data['partner_code'];

      if (userCode == null || partnerCode == null || userCode.isEmpty || partnerCode.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Códigos do usuário e do parceiro são obrigatórios'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final partnerResult = await db.query(
        'SELECT * FROM usuarios WHERE codigo_usuario = @partner_code',
        substitutionValues: {'partner_code': partnerCode},
      );

      if (partnerResult.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Código do parceiro não encontrado'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final partner = partnerResult.first;
      final partnerData = {
        'id': partner[0],
        'status_vinculo': partner[6],
        'foto_url': partner[7],
      };

      if (partnerData['status_vinculo'] == 'vinculado') {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Este parceiro já está vinculado a outro usuário'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Código do parceiro válido',
          'partner_id': partnerData['id'],
          'foto_url': partnerData['foto_url'],
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Erro ao verificar código do parceiro: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Erro ao verificar código: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Endpoint para registrar a solicitação de vínculo e verificar status
  router.post('/solicitar-vinculo', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userCode = data['user_code'];
      final partnerCode = data['partner_code'];

      if (userCode == null || partnerCode == null || userCode.isEmpty || partnerCode.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Códigos do usuário e do parceiro são obrigatórios'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await db.query(
        'UPDATE usuarios SET codigo_parceiro = @partner_code, status_vinculo = @status WHERE codigo_usuario = @user_code',
        substitutionValues: {
          'partner_code': partnerCode,
          'status': 'pendente',
          'user_code': userCode,
        },
      );

      final userResult = await db.query(
        'SELECT * FROM usuarios WHERE codigo_usuario = @user_code',
        substitutionValues: {'user_code': userCode},
      );

      final partnerResult = await db.query(
        'SELECT * FROM usuarios WHERE codigo_usuario = @partner_code',
        substitutionValues: {'partner_code': partnerCode},
      );

      if (userResult.isEmpty || partnerResult.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Usuário ou parceiro não encontrado'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = userResult.first;
      final partner = partnerResult.first;

      if (user[5] == partnerCode && partner[5] == userCode) {
        await db.query(
          'UPDATE usuarios SET status_vinculo = @status WHERE codigo_usuario IN (@user_code, @partner_code)',
          substitutionValues: {
            'status': 'vinculado',
            'user_code': userCode,
            'partner_code': partnerCode,
          },
        );
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Vínculo confirmado com sucesso',
            'status': 'vinculado',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Aguardando confirmação do parceiro',
            'status': 'pendente',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      print('Erro ao solicitar vínculo: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Erro ao solicitar vínculo: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Middleware CORS
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware)
      .addHandler(router);

  try {
    final server = await shelf_io.serve(handler, 'localhost', 8080);
    print('Server running on localhost:${server.port}');
  } catch (e) {
    print('Error starting server: $e');
  }
}

Response _options(Request request) => Response.ok('', headers: _corsHeaders);

final _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
};

Middleware _corsMiddleware = (Handler handler) {
  return (Request request) async {
    if (request.method == 'OPTIONS') {
      return _options(request);
    }
    final response = await handler(request);
    return response.change(headers: _corsHeaders);
  };
};