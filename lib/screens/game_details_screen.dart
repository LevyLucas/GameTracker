import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../providers/game_provider.dart';
import 'add_review_screen.dart';

class GameDetailsScreen extends StatelessWidget {
  final int gameId;

  GameDetailsScreen({required this.gameId});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final game = gameProvider.games.firstWhere((game) => game['id'] == gameId);
    final reviewProvider = Provider.of<ReviewProvider>(context);

    reviewProvider.fetchReviews(gameId);

    return Scaffold(
      appBar: AppBar(title: Text('Game Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              game['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Release Date: ${game['release_date']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              game['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Consumer<ReviewProvider>(
                builder: (context, reviewProvider, child) {
                  if (reviewProvider.reviews.isEmpty) {
                    return Center(child: Text('No reviews found'));
                  } else {
                    return ListView.builder(
                      itemCount: reviewProvider.reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviewProvider.reviews[index];
                        return ListTile(
                          title: Text('Score: ${review['score']}'),
                          subtitle: Text(review['description']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              reviewProvider.deleteReview(review['id'], gameId);
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddReviewScreen(gameId: gameId)),
                );
              },
              child: Text('Add Review'),
            ),
          ],
        ),
      ),
    );
  }
}
