import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'games_tracker.db');
    print('Database path: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        await _insertInitialData(db);
      },
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
  }

  Future<void> _insertInitialData(Database db) async {
    // Inserindo dados iniciais nas tabelas, se ainda não estiverem presentes
    var result = await db.rawQuery('SELECT COUNT(*) as count FROM user');
    int userCount = Sqflite.firstIntValue(result) ?? 0;

    if (userCount == 0) {
      print('Inserting initial data...');
      
      await db.insert('user', {'name': 'Teste 1', 'email': 'teste1@teste', 'password': '123456'});
      await db.insert('user', {'name': 'Teste 2', 'email': 'teste2@teste', 'password': '123456'});
      await db.insert('user', {'name': 'Teste 3', 'email': 'teste3@teste', 'password': '123456'});
      await db.insert('user', {'name': 'Teste 4', 'email': 'teste4@teste', 'password': '123456'});
      await db.insert('user', {'name': 'Teste 5', 'email': 'teste5@teste', 'password': '123456'});
      print('Inserted initial users');

      await db.insert('genre', {'name': 'Aventura'});
      await db.insert('genre', {'name': 'Ação'});
      await db.insert('genre', {'name': 'RPG'});
      await db.insert('genre', {'name': 'Plataforma'});
      await db.insert('genre', {'name': 'Metroidvania'});
      await db.insert('genre', {'name': 'Rogue Lite'});
      await db.insert('genre', {'name': 'Survival Horror'});
      await db.insert('genre', {'name': 'Mundo Aberto'});
      await db.insert('genre', {'name': 'MOBA'});
      print('Inserted initial genres');

      await db.insert('game', {'user_id': 1, 'name': 'God of War', 'description': 'O jogo começa após a morte da segunda esposa de Kratos e mãe de Atreus, Faye. Seu último desejo era que suas cinzas fossem espalhadas no pico mais alto dos nove reinos nórdicos. Antes de iniciar sua jornada, Kratos é confrontado por um homem misterioso com poderes divinos.', 'release_date': '2018-04-18'});
      await db.insert('game', {'user_id': 1, 'name': 'Resident Evil 4', 'description': 'Resident Evil 4 é um jogo de terror e sobrevivência no qual os jogadores terão que enfrentar situações extremas de medo. Apesar dos vários elementos de terror, o jogo é equilibrado com muita ação e uma experiência de jogo bastante variada.', 'release_date': '2023-03-24'});
      await db.insert('game', {'user_id': 2, 'name': 'Persona 5', 'description': 'Transferido para a Academia Shujin, em Tóquio, Ren Amamiya está prestes a entrar no segundo ano do colegial. Após um certo incidente, sua Persona desperta, e junto com seus amigos eles formam os Ladrões-Fantasma de Corações, para roubar a fonte dos desejos deturpados dos adultos e assim reformar seus corações.', 'release_date': '2017-04-17'});
      await db.insert('game', {'user_id': 3, 'name': 'Horizon Zero Dawn', 'description': 'Horizon Zero Dawn é um RPG eletrônico de ação em que os jogadores controlam a protagonista Aloy, uma caçadora e arqueira, em um cenário futurista, um mundo aberto pós-apocalíptico dominado por criaturas mecanizadas como robôs dinossauros.', 'release_date': '2017-02-28'});
      await db.insert('game', {'user_id': 4, 'name': 'The Last of Us Part II', 'description': 'Cinco anos após os eventos do primeiro jogo, Ellie embarca em uma nova jornada em busca de vingança e justiça, enfrentando desafios emocionais e físicos.', 'release_date': '2020-06-19'});
      await db.insert('game', {'user_id': 5, 'name': 'League of Legends', 'description': 'League of Legends, também conhecido como LOL, é um jogo de estratégia em que duas equipes de cinco poderosos Campeões se enfrentam para destruir a base uma da outra. Escolha entre mais de 140 Campeões para realizar jogadas épicas, assegurar abates e destruir torres conforme você luta até a vitória.', 'release_date': '2009-10-27'});
      print('Inserted initial games');

      await db.insert('game_genre', {'game_id': 1, 'genre_id': 1});
      await db.insert('game_genre', {'game_id': 2, 'genre_id': 7});
      await db.insert('game_genre', {'game_id': 3, 'genre_id': 3});
      await db.insert('game_genre', {'game_id': 4, 'genre_id': 2});
      await db.insert('game_genre', {'game_id': 4, 'genre_id': 3});
      await db.insert('game_genre', {'game_id': 4, 'genre_id': 8});
      await db.insert('game_genre', {'game_id': 5, 'genre_id': 1});
      await db.insert('game_genre', {'game_id': 5, 'genre_id': 7});
      await db.insert('game_genre', {'game_id': 6, 'genre_id': 9});
      print('Inserted initial game_genre relationships');

      await db.insert('review', {'user_id': 1, 'game_id': 1, 'score': 9.5, 'description': 'Incrível história e jogabilidade.', 'date': '2024-06-20'});
      await db.insert('review', {'user_id': 2, 'game_id': 1, 'score': 9.0, 'description': 'Gráficos impressionantes.', 'date': '2024-06-21'});
      await db.insert('review', {'user_id': 3, 'game_id': 1, 'score': 8.5, 'description': 'Ótima mecânica de combate.', 'date': '2024-06-22'});
      await db.insert('review', {'user_id': 4, 'game_id': 1, 'score': 9.6, 'description': 'Narrativa envolvente.', 'date': '2024-06-23'});
      await db.insert('review', {'user_id': 2, 'game_id': 2, 'score': 10.0, 'description': 'Perfeito em todos os sentidos.', 'date': '2024-06-24'});
      await db.insert('review', {'user_id': 1, 'game_id': 3, 'score': 7.5, 'description': 'Interessante, mas um pouco repetitivo.', 'date': '2024-06-25'});
      await db.insert('review', {'user_id': 3, 'game_id': 4, 'score': 8.0, 'description': 'Bela direção de arte.', 'date': '2024-06-26'});
      await db.insert('review', {'user_id': 4, 'game_id': 5, 'score': 9.8, 'description': 'Experiência emocionalmente intensa.', 'date': '2024-06-27'});
      await db.insert('review', {'user_id': 5, 'game_id': 6, 'score': 4.2, 'description': 'Esse jogo desgraçou a minha vida.', 'date': '2024-06-30'});
      print('Inserted initial reviews');
    }
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
