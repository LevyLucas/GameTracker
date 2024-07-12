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
    Provider.of<ReviewProvider>(context, listen: false).fetchReviews(widget.gameId);
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
            return Center(child: Text('Nenhum jogo encontrado'));
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.blueGrey[900],
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gameDetails!['name'],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          gameDetails!['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.date_range, color: Colors.white70),
                            SizedBox(width: 5),
                            Text(
                              'Release Date: ${gameDetails!['release_date']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.category, color: Colors.white70),
                            SizedBox(width: 5),
                            Text(
                              'Genre(s): ${gameGenres?.map((genre) => genre['name']).join(', ') ?? 'None'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.blueGrey),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                  ),
                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, child) {
                      final reviews = reviewProvider.reviews;
                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            elevation: 4.0,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: ListTile(
                              title: Text(
                                'Score: ${review['score']}',
                                style: TextStyle(
                                  color: Colors.blueGrey[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                review['description'],
                                style: TextStyle(color: Colors.blueGrey[700]),
                              ),
                              trailing: userId != null &&
                                      userId == review['user_id']
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.blueGrey),
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
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            Provider.of<ReviewProvider>(context,
                                                    listen: false)
                                                .deleteReview(review['id']);
                                          },
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
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
                    builder: (context) => AddReviewScreen(gameId: widget.gameId),
                  ),
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blueGrey[900],
            )
          : null,
    );
  }
}
