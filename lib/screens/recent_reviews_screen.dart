import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../database_helper.dart';
import 'package:intl/intl.dart';

class RecentReviewsScreen extends StatefulWidget {
  @override
  _RecentReviewsScreenState createState() => _RecentReviewsScreenState();
}

class _RecentReviewsScreenState extends State<RecentReviewsScreen> {
  late Future<List<Map<String, dynamic>>> _recentReviews;

  @override
  void initState() {
    super.initState();
    _recentReviews = _fetchRecentReviews();
  }

  Future<List<Map<String, dynamic>>> _fetchRecentReviews() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final reviews = await db.rawQuery('''
      SELECT review.*, game.name as game_name, user.name as user_name
      FROM review
      JOIN game ON review.game_id = game.id
      JOIN user ON review.user_id = user.id
      WHERE date >= date('now', '-180 days')
      ORDER BY date DESC
    ''');
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recent Reviews')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recentReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Sem reviews recentes'));
          } else {
            final reviews = snapshot.data!;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Game: ${review['game_name']}',
                          style: TextStyle(
                            color: Colors.blueGrey[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'User: ${review['user_name']}',
                          style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Score: ${review['score']}',
                          style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(review['date']))}',
                          style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Review: ${review['description']}',
                          style: TextStyle(
                            color: Colors.blueGrey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
