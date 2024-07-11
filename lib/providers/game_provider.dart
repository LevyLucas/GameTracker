import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'package:intl/intl.dart';

class GameProvider with ChangeNotifier {
  DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> _games = [];

  List<Map<String, dynamic>> get games => _games;

  Future<void> fetchGames({int? genreId, double? minScore, double? maxScore, DateTime? startDate, DateTime? endDate}) async {
    final db = await _dbHelper.database;
    String query = '''
      SELECT g.*, AVG(r.score) as avg_score 
      FROM game g 
      LEFT JOIN review r ON g.id = r.game_id
      LEFT JOIN game_genre gg ON g.id = gg.game_id
      WHERE 1 = 1
    ''';
    List<dynamic> args = [];

    if (genreId != null) {
      query += ' AND gg.genre_id = ?';
      args.add(genreId);
    }
    if (minScore != null) {
      query += ' AND r.score >= ?';
      args.add(minScore);
    }
    if (maxScore != null) {
      query += ' AND r.score <= ?';
      args.add(maxScore);
    }
    if (startDate != null) {
      query += ' AND g.release_date >= ?';
      args.add(DateFormat('yyyy-MM-dd').format(startDate));
    }
    if (endDate != null) {
      query += ' AND g.release_date <= ?';
      args.add(DateFormat('yyyy-MM-dd').format(endDate));
    }

    query += ' GROUP BY g.id';

    final games = await db.rawQuery(query, args);
    _games = games;
    notifyListeners();
  }

  Future<void> addGame(Map<String, dynamic> game, int genreId) async {
    final db = await _dbHelper.database;
    int gameId = await db.insert('game', game);
    await db.insert('game_genre', {
      'game_id': gameId,
      'genre_id': genreId,
    });
    fetchGames();
  }

  Future<void> updateGame(int id, Map<String, dynamic> game, int genreId) async {
    final db = await _dbHelper.database;
    await db.update('game', game, where: 'id = ?', whereArgs: [id]);
    await db.update('game_genre', {'genre_id': genreId},
        where: 'game_id = ?', whereArgs: [id]);
    fetchGames();
  }

  Future<void> deleteGame(int id) async {
    final db = await _dbHelper.database;
    await db.delete('game', where: 'id = ?', whereArgs: [id]);
    await db.delete('game_genre', where: 'game_id = ?', whereArgs: [id]);
    fetchGames();
  }
}
