import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'add_edit_game_screen.dart';
import 'game_details_screen.dart';
import 'recent_reviews_screen.dart';
import 'manage_genres_screen.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../database_helper.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _selectedGenre;
  double? _minScore;
  double? _maxScore;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Map<String, dynamic>> _genres = [];

  @override
  void initState() {
    super.initState();
    Provider.of<GameProvider>(context, listen: false).fetchGames();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    final dbHelper = DatabaseHelper();
    final genres = await dbHelper.getGenres();
    setState(() {
      _genres = genres;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
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
              } else if (value == 'manage_genres') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageGenresScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Recent Reviews', 'Manage Genres'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice.toLowerCase().replaceAll(' ', '_'),
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGenre,
                        hint: Text('Select Genre'),
                        items: _genres.map((genre) {
                          return DropdownMenuItem<String>(
                            value: genre['id'].toString(),
                            child: Text(genre['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGenre = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Min Score'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _minScore = double.tryParse(value);
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Max Score'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _maxScore = double.tryParse(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _startDate != null
                                ? DateFormat.yMd().format(_startDate!)
                                : 'Select date',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _endDate != null
                                ? DateFormat.yMd().format(_endDate!)
                                : 'Select date',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<GameProvider>(context, listen: false).fetchGames(
                      genreId: _selectedGenre != null ? int.parse(_selectedGenre!) : null,
                      minScore: _minScore,
                      maxScore: _maxScore,
                      startDate: _startDate,
                      endDate: _endDate,
                    );
                  },
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<GameProvider>(
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
                        subtitle: Text('Average Score: ${(game['avg_score'] != null ? game['avg_score'].toStringAsFixed(1) : 'N/A')}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GameDetailsScreen(gameId: game['id'] as int)),
                          );
                        },
                        trailing: userId != null && game['user_id'] == userId
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
          ),
        ],
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
