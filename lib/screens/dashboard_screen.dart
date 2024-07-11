import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_edit_game_screen.dart';
import 'game_details_screen.dart';
import 'recent_reviews_screen.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<GameProvider>(context, listen: false).fetchGames();
  }

  @override
  Widget build(BuildContext context) {
    int? userId = Provider.of<UserProvider>(context).userId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Provider.of<UserProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/');
              } else if (value == 'recent_reviews') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecentReviewsScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Recent Reviews'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice.toLowerCase().replaceAll(' ', '_'),
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.games.isEmpty) {
            return Center(child: Text('No games found'));
          } else {
            return ListView.builder(
              itemCount: gameProvider.games.length,
              itemBuilder: (context, index) {
                final game = gameProvider.games[index];
                return ListTile(
                  title: Text(game['name']),
                  subtitle: Text('Average Score: ${game['avg_score'].toStringAsFixed(1)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameDetailsScreen(gameId: game['id'] as int)),
                    );
                  },
                  trailing: userId != null && userId == game['user_id']
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddEditGameScreen(game: game)),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                Provider.of<GameProvider>(context, listen: false).deleteGame(game['id'] as int);
                              },
                            ),
                          ],
                        )
                      : null,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: userId != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEditGameScreen()),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
