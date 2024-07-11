import 'package:flutter/material.dart';
import '../database_helper.dart';

class ReviewProvider with ChangeNotifier {
  DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> _reviews = [];

  List<Map<String, dynamic>> get reviews => _reviews;

  Future<void> fetchReviews(int gameId) async {
    final db = await _dbHelper.database;
    final reviews = await db.query('review', where: 'game_id = ?', whereArgs: [gameId]);
    _reviews = reviews;
    notifyListeners();
  }

  Future<void> addReview(Map<String, dynamic> review) async {
    final db = await _dbHelper.database;
    await db.insert('review', review);
    fetchReviews(review['game_id']);
  }

  Future<void> updateReview(int id, Map<String, dynamic> review) async {
    final db = await _dbHelper.database;
    await db.update('review', review, where: 'id = ?', whereArgs: [id]);
    fetchReviews(review['game_id']);
  }

  Future<void> deleteReview(int id, int gameId) async {
    final db = await _dbHelper.database;
    await db.delete('review', where: 'id = ?', whereArgs: [id]);
    fetchReviews(gameId);
  }
}
