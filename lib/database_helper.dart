import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  late Database _database;

  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'games_tracker.db');
    print('Database path: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    print('Creating database...');
    await db.execute('''
      CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL,
        email VARCHAR NOT NULL,
        password VARCHAR NOT NULL
      )
    ''');
    print('Created table user');

    await db.execute('''
      CREATE TABLE genre(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL
      )
    ''');
    print('Created table genre');

    await db.execute('''
      CREATE TABLE game(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name VARCHAR NOT NULL UNIQUE,
        description TEXT NOT NULL,
        release_date VARCHAR NOT NULL,   
        FOREIGN KEY(user_id) REFERENCES user(id)
      )
    ''');
    print('Created table game');

    await db.execute('''
      CREATE TABLE game_genre(
        game_id INTEGER NOT NULL,
        genre_id INTEGER NOT NULL,
        FOREIGN KEY(game_id) REFERENCES game(id),
        FOREIGN KEY(genre_id) REFERENCES genre(id)
      )
    ''');
    print('Created table game_genre');

    await db.execute('''
      CREATE TABLE review(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        game_id INTEGER NOT NULL,
        score REAL NOT NULL,
        description TEXT NOT NULL,
        date VARCHAR NOT NULL,
        FOREIGN KEY(user_id) REFERENCES user(id),
        FOREIGN KEY(game_id) REFERENCES game(id)
      )
    ''');
    print('Created table review');

    // Inserindo dados iniciais nas tabelas
    await db.execute('''
      INSERT INTO user(name, email, password) VALUES('Teste 1', 'teste1@teste', '123456');
      INSERT INTO user(name, email, password) VALUES('Teste 2', 'teste2@teste', '123456');
      INSERT INTO user(name, email, password) VALUES('Teste 3', 'teste3@teste', '123456');
      INSERT INTO user(name, email, password) VALUES('Teste 4', 'teste4@teste', '123456');
      INSERT INTO user(name, email, password) VALUES('Teste 5', 'teste5@teste', '123456');
    ''');
    print('Inserted initial users');

    await db.execute('''
      INSERT INTO genre(name) VALUES('Aventura');
      INSERT INTO genre(name) VALUES('Ação');
      INSERT INTO genre(name) VALUES('RPG');
      INSERT INTO genre(name) VALUES('Plataforma');
      INSERT INTO genre(name) VALUES('Metroidvania');
      INSERT INTO genre(name) VALUES('Rogue Lite');
      INSERT INTO genre(name) VALUES('Survival Horror');
      INSERT INTO genre(name) VALUES('Mundo Aberto');
    ''');
    print('Inserted initial genres');

    await db.execute('''
      INSERT INTO game(user_id, name, description, release_date) VALUES(1, 'God of War', 'O jogo começa após a morte da segunda esposa de Kratos e mãe de Atreus, Faye. Seu último desejo era que suas cinzas fossem espalhadas no pico mais alto dos nove reinos nórdicos. Antes de iniciar sua jornada, Kratos é confrontado por um homem misterioso com poderes divinos.', '2018-04-18');
      INSERT INTO game(user_id, name, description, release_date) VALUES(1, 'Resident Evil 4', 'Resident Evil 4 é um jogo de terror e sobrevivência no qual os jogadores terão que enfrentar situações extremas de medo. Apesar dos vários elementos de terror, o jogo é equilibrado com muita ação e uma experiência de jogo bastante variada.', '2023-03-24');
      INSERT INTO game(user_id, name, description, release_date) VALUES(2, 'Persona 5', 'Transferido para a Academia Shujin, em Tóquio, Ren Amamiya está prestes a entrar no segundo ano do colegial. Após um certo incidente, sua Persona desperta, e junto com seus amigos eles formam os Ladrões-Fantasma de Corações, para roubar a fonte dos desejos deturpados dos adultos e assim reformar seus corações.', '2017-04-17');
      INSERT INTO game(user_id, name, description, release_date) VALUES(3, 'Horizon Zero Dawn', 'Horizon Zero Dawn é um RPG eletrônico de ação em que os jogadores controlam a protagonista Aloy, uma caçadora e arqueira, em um cenário futurista, um mundo aberto pós-apocalíptico dominado por criaturas mecanizadas como robôs dinossauros.', '2017-02-28');
    ''');
    print('Inserted initial games');

    await db.execute('''
      INSERT INTO game_genre(game_id, genre_id) VALUES(1, 1);
      INSERT INTO game_genre(game_id, genre_id) VALUES(2, 7);
      INSERT INTO game_genre(game_id, genre_id) VALUES(3, 3);
      INSERT INTO game_genre(game_id, genre_id) VALUES(4, 2);
      INSERT INTO game_genre(game_id, genre_id) VALUES(4, 3);
      INSERT INTO game_genre(game_id, genre_id) VALUES(4, 8);
    ''');
    print('Inserted initial game_genre relationships');

    await db.execute('''
      INSERT INTO review(user_id, game_id, score, description, date) VALUES(1, 1, 9.5, 'Teste', '2024-06-20');
      INSERT INTO review(user_id, game_id, score, description, date) VALUES(2, 1, 9.0, 'Teste', '2024-06-20');
      INSERT INTO review(user_id, game_id, score, description, date) VALUES(3, 1, 8.5, 'Teste', '2024-06-20');
      INSERT INTO review(user_id, game_id, score, description, date) VALUES(4, 1, 9.6, 'Teste', '2024-06-20');
    ''');
    print('Inserted initial reviews');
  }

  Future<int> registerUser(String name, String email, String password) async {
    final db = await database;
    try {
      return await db
          .insert('user', {'name': name, 'email': email, 'password': password});
    } catch (e) {
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getRecentReviews() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM review WHERE date >= date("now", "-180 days")');
    return result;
  }

  Future<double> getAverageScore(int gameId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT AVG(score) as avg_score FROM review WHERE game_id = ?',
      [gameId],
    );
    if (result.isNotEmpty && result.first['avg_score'] != null) {
      return result.first['avg_score'] as double;
    } else {
      return 0.0;
    }
  }

  Future<int?> validateUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    } else {
      return null;
    }
  }

  Future<void> addGenre(String name) async {
    final db = await database;
    await db.insert('genre', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getGenres() async {
    final db = await database;
    return await db.query('genre');
  }

  Future<List<Map<String, dynamic>>> getGameGenres(int gameId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT g.name FROM genre g
      INNER JOIN game_genre gg ON gg.genre_id = g.id
      WHERE gg.game_id = ?
    ''', [gameId]);
  }
}
