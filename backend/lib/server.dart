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

  try {
    await db.query('''
      CREATE TABLE IF NOT EXISTS relacionamentos (
        id SERIAL PRIMARY KEY,
        user_code TEXT NOT NULL REFERENCES usuarios(codigo_usuario),
        partner_code TEXT NOT NULL REFERENCES usuarios(codigo_usuario),
        data_inicio DATE,
        mensagem TEXT,
        foto_base64 TEXT,
        criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_code, partner_code)
      );
    ''');
    print('Table "relacionamentos" created or already exists.');
  } catch (e) {
    print('Error creating table relacionamentos: $e');
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

      print('Dados recebidos - nome: $nome, email: $email, foto_url: ${fotoUrl.substring(0, 50)}...');

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
        'SELECT id, nome, email, senha, codigo_usuario, codigo_parceiro, status_vinculo, foto_url FROM usuarios WHERE email = @email AND senha = @senha',
        substitutionValues: {
          'email': email,
          'senha': senha,
        },
      );

      if (result.isNotEmpty) {
        final user = result.first;
        final userData = {
          'id': user[0] as int,
          'nome': user[1] as String,
          'email': user[2] as String,
          'codigo_usuario': user[4] as String,
          'status_vinculo': user[6] as String,
          'foto_url': user[7] as String,
          'codigo_parceiro': user[5] as String?,
        };

        // Verifica se já existe relacionamento configurado
        final relResult = await db.query(
          'SELECT COUNT(*) FROM relacionamentos WHERE user_code = @user_code OR partner_code = @user_code',
          substitutionValues: {'user_code': userData['codigo_usuario']},
        );
        final hasRelationship = (relResult.first[0] as int) > 0;

        print('Login successful - User data: $userData, hasRelationship: $hasRelationship');
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Login realizado com sucesso',
            'codigo_usuario': userData['codigo_usuario'],
            'status_vinculo': userData['status_vinculo'],
            'foto_url': userData['foto_url'],
            'nome': userData['nome'],
            'id': userData['id'],
            'codigo_parceiro': userData['codigo_parceiro'],
            'has_relationship': hasRelationship,
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

      if (userCode == null || userCode.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Código do usuário é obrigatório'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (partnerCode == null || partnerCode.isEmpty) {
        final userResult = await db.query(
          'SELECT codigo_parceiro, status_vinculo FROM usuarios WHERE codigo_usuario = @user_code',
          substitutionValues: {'user_code': userCode},
        );

        if (userResult.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'success': false, 'message': 'Usuário não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final user = userResult.first;
        final storedPartnerCode = user[0] as String?;
        final statusVinculo = user[1] as String;

        if (statusVinculo != 'vinculado' || storedPartnerCode == null || storedPartnerCode.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'success': false, 'message': 'Usuário não está vinculado a um parceiro'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final partnerResult = await db.query(
          'SELECT id, nome, foto_url FROM usuarios WHERE codigo_usuario = @partner_code',
          substitutionValues: {'partner_code': storedPartnerCode},
        );

        if (partnerResult.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'success': false, 'message': 'Parceiro não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final partner = partnerResult.first;
        final partnerData = {
          'id': partner[0],
          'nome': partner[1],
          'foto_url': partner[2],
        };

        print('Partner data returned: $partnerData');
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Parceiro encontrado',
            'partner_id': partnerData['id'],
            'nome': partnerData['nome'],
            'foto_url': partnerData['foto_url'],
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final partnerResult = await db.query(
        'SELECT id, nome, foto_url, status_vinculo FROM usuarios WHERE codigo_usuario = @partner_code',
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
        'nome': partner[1],
        'foto_url': partner[2],
        'status_vinculo': partner[3],
      };

      if (partnerData['status_vinculo'] == 'vinculado') {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Este parceiro já está vinculado a outro usuário'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      print('Partner data returned: $partnerData');
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Código do parceiro válido',
          'partner_id': partnerData['id'],
          'nome': partnerData['nome'],
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

      // Verifica se o usuário já está vinculado
      final userResult = await db.query(
        'SELECT codigo_parceiro, status_vinculo FROM usuarios WHERE codigo_usuario = @user_code',
        substitutionValues: {'user_code': userCode},
      );

      if (userResult.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Usuário não encontrado'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = userResult.first;
      final currentPartnerCode = user[0] as String?;
      final currentStatus = user[1] as String;

      if (currentStatus == 'vinculado' && currentPartnerCode != null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Usuário já está vinculado a outro parceiro'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Verifica se o parceiro existe
      final partnerResult = await db.query(
        'SELECT codigo_parceiro, status_vinculo FROM usuarios WHERE codigo_usuario = @partner_code',
        substitutionValues: {'partner_code': partnerCode},
      );

      if (partnerResult.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Parceiro não encontrado'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final partner = partnerResult.first;
      final partnerCurrentPartnerCode = partner[0] as String?;
      final partnerStatus = partner[1] as String;

      if (partnerStatus == 'vinculado' && partnerCurrentPartnerCode != null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Parceiro já está vinculado a outro usuário'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Atualiza o status do usuário iniciador para 'pendente'
      await db.query(
        'UPDATE usuarios SET codigo_parceiro = @partner_code, status_vinculo = @status WHERE codigo_usuario = @user_code',
        substitutionValues: {
          'partner_code': partnerCode,
          'status': 'pendente',
          'user_code': userCode,
        },
      );

      // Verifica se o parceiro já enviou uma solicitação de vínculo
      if (partnerCurrentPartnerCode == userCode) {
        // Ambos os usuários confirmaram, atualiza para 'vinculado'
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
        // Aguarda confirmação do parceiro
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

  // Endpoint para atualizar informações do relacionamento
  router.post('/atualizar-relacionamento', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final userCode = data['user_code'];
      final partnerCode = data['partner_code'];
      final dataInicio = data['data_inicio'];
      final mensagem = data['mensagem'];
      final fotoBase64 = data['foto_base64'] ?? '';

      if (userCode == null || partnerCode == null || userCode.isEmpty || partnerCode.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Códigos do usuário e do parceiro são obrigatórios'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Verifica se o vínculo existe
      final vinculoResult = await db.query(
        'SELECT * FROM usuarios WHERE codigo_usuario = @user_code AND codigo_parceiro = @partner_code AND status_vinculo = @status',
        substitutionValues: {
          'user_code': userCode,
          'partner_code': partnerCode,
          'status': 'vinculado',
        },
      );

      if (vinculoResult.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Vínculo não encontrado ou não está confirmado'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Insere ou atualiza as informações na tabela relacionamentos
      final result = await db.query(
        '''
        INSERT INTO relacionamentos (user_code, partner_code, data_inicio, mensagem, foto_base64)
        VALUES (@user_code, @partner_code, @data_inicio, @mensagem, @foto_base64)
        ON CONFLICT (user_code, partner_code)
        DO UPDATE SET data_inicio = @data_inicio, mensagem = @mensagem, foto_base64 = @foto_base64
        RETURNING id
        ''',
        substitutionValues: {
          'user_code': userCode,
          'partner_code': partnerCode,
          'data_inicio': dataInicio,
          'mensagem': mensagem ?? '',
          'foto_base64': fotoBase64,
        },
      );

      if (result.isNotEmpty) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Informações do relacionamento atualizadas com sucesso',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Falha ao atualizar informações do relacionamento'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      print('Erro ao atualizar relacionamento: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Erro ao atualizar relacionamento: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Endpoint para obter informações do relacionamento
  router.post('/obter-relacionamento', (Request request) async {
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

      // Busca as informações do relacionamento definidas pelo parceiro
      final result = await db.query(
        'SELECT data_inicio, mensagem, foto_base64 FROM relacionamentos WHERE user_code = @partner_code AND partner_code = @user_code',
        substitutionValues: {
          'user_code': userCode,
          'partner_code': partnerCode,
        },
      );

      print('Query result for user_code: $userCode, partner_code: $partnerCode: $result');

      if (result.isNotEmpty) {
        final partnerRecord = result.first;
        return Response.ok(
          jsonEncode({
            'success': true,
            'data_inicio': partnerRecord[0]?.toIso8601String(),
            'mensagem': partnerRecord[1] as String? ?? '',
            'foto_base64': partnerRecord[2] as String? ?? '',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        // Se não houver dados do parceiro, retorna dados vazios
        return Response.ok(
          jsonEncode({
            'success': true,
            'data_inicio': null,
            'mensagem': '',
            'foto_base64': '',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      print('Erro ao obter relacionamento: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Erro ao obter relacionamento: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware)
      .addHandler(router);

  try {
    final server = await shelf_io.serve(handler, '0.0.0.0', 8080);
    print('Server running on 0.0.0.0:${server.port}');
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