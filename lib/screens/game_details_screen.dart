import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../providers/user_provider.dart';
import '../database_helper.dart';
import 'add_review_screen.dart';

class GameDetailsScreen extends StatefulWidget {
  final int gameId;

  GameDetailsScreen({required this.gameId});

  @override
  _GameDetailsScreenState createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  Map<String, dynamic>? gameDetails;
  List<Map<String, dynamic>>? gameGenres;
  late Future<void> _loadGameDetailsFuture;

  @override
  void initState() {
    super.initState();
    _loadGameDetailsFuture = _loadGameDetails();
  }

  Future<void> _loadGameDetails() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.query(
      'game',
      where: 'id = ?',
      whereArgs: [widget.gameId],
    );
    final genres = await dbHelper.getGameGenres(widget.gameId);
    if (result.isNotEmpty) {
      setState(() {
        gameDetails = result.first;
        gameGenres = genres;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Game Details'),
      ),
      body: FutureBuilder<void>(
        future: _loadGameDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (gameDetails == null) {
            return Center(child: Text('Game not found'));
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gameDetails!['name'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        gameDetails!['description'],
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Release Date: ${gameDetails!['release_date']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Genres: ${gameGenres?.map((genre) => genre['name']).join(', ') ?? 'None'}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, child) {
                      final reviews = reviewProvider.reviews;
                      return ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return ListTile(
                            title: Text('Score: ${review['score']}'),
                            subtitle: Text(review['description']),
                            trailing: userId != null &&
                                    userId == review['user_id']
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddReviewScreen(
                                                review: review,
                                                gameId: widget.gameId,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          Provider.of<ReviewProvider>(context,
                                                  listen: false)
                                              .deleteReview(review['id']);
                                        },
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: userId != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddReviewScreen(gameId: widget.gameId),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
