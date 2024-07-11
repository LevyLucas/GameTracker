import 'package:flutter/material.dart';
import '../database_helper.dart';

class GameProvider with ChangeNotifier {
  DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> _games = [];

  List<Map<String, dynamic>> get games => _games;

  Future<void> fetchGames() async {
    final db = await _dbHelper.database;
    final games = await db.query('game');
    List<Map<String, dynamic>> updatedGames = [];
    for (var game in games) {
      double avgScore = await _dbHelper.getAverageScore(game['id'] as int);
      updatedGames.add({...game, 'avg_score': avgScore});
    }
    _games = updatedGames;
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
