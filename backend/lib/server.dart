import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';

// Configurações do banco
final db = PostgreSQLConnection(
  'localhost',
  5432,
  'ties_of_love', // Nome do seu banco
  username: 'postgres', // Seu usuário
  password: '123', // Sua senha
);

void main() async {
  print('Attempting to connect to database...');
  await db.open();
  print('Database connected successfully!');

  // Criar tabela se não existir
  await db.query('''
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      nome TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      senha TEXT NOT NULL
    );
  ''');

  final router = Router();

  // Endpoint de cadastro
  router.post('/cadastrar', (Request request) async {
    try {
      // Verifica se a conexão com o banco está ativa
      if (db.isClosed) {
        await db.open();
        print('Reopened database connection');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body);

      // Validação dos dados
      final nome = data['nome'];
      final email = data['email'];
      final senha = data['senha'];

      if (nome == null || email == null || senha == null || nome.isEmpty || email.isEmpty || senha.isEmpty) {
        return Response.badRequest(body: 'Campos nome, email e senha são obrigatórios e não podem estar vazios');
      }

      // Inserção no banco
      final result = await db.query(
        'INSERT INTO usuarios (nome, email, senha) VALUES (@nome, @email, @senha) RETURNING id',
        substitutionValues: {
          'nome': nome,
          'email': email,
          'senha': senha,
        },
      );

      // Verifica se a inserção foi bem-sucedida
      if (result.isNotEmpty) {
        print('Usuário inserido com sucesso: ID ${result[0][0]}');
        return Response.ok('Usuário cadastrado com sucesso');
      } else {
        print('Falha ao inserir usuário: nenhuma linha afetada');
        return Response.internalServerError(body: 'Falha ao cadastrar: nenhuma linha afetada');
      }
    } catch (e) {
      print('Erro ao cadastrar: $e');
      return Response.internalServerError(body: 'Erro ao cadastrar: $e');
    }
  });

  // Endpoint de login (sem alterações por enquanto)
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
        return Response.ok('Login realizado com sucesso');
      } else {
        return Response.forbidden('Email ou senha inválidos');
      }
    } catch (e) {
      return Response.internalServerError(body: 'Erro no login: $e');
    }
  });

  // Middleware CORS para permitir acesso do app Flutter
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware)
      .addHandler(router);

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Server running on localhost:${server.port}');
}

// Middleware CORS
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