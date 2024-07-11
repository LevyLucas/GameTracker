import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../database_helper.dart';

class AddEditGameScreen extends StatefulWidget {
  final Map<String, dynamic>? game;

  AddEditGameScreen({this.game});

  @override
  _AddEditGameScreenState createState() => _AddEditGameScreenState();
}

class _AddEditGameScreenState extends State<AddEditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _releaseDate;
  int? _selectedGenre;
  List<Map<String, dynamic>> _genres = [];

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      _name = widget.game!['name'];
      _description = widget.game!['description'];
      _releaseDate = widget.game!['release_date'];
      _selectedGenre = widget.game!['genre_id'];
    }
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    final dbHelper = DatabaseHelper();
    final genres = await dbHelper.getGenres();
    setState(() {
      _genres = genres;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game == null ? 'Add Game' : 'Edit Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.game != null ? widget.game!['name'] : '',
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira um nome';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: widget.game != null ? widget.game!['description'] : '',
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira uma descrição';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                initialValue: widget.game != null ? widget.game!['release_date'] : '',
                decoration: InputDecoration(labelText: 'Release Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira uma data de lançamento';
                  }
                  return null;
                },
                onSaved: (value) => _releaseDate = value!,
              ),
              DropdownButtonFormField<int>(
                value: _selectedGenre,
                decoration: InputDecoration(labelText: 'Genre'),
                items: _genres.map((genre) {
                  return DropdownMenuItem<int>(
                    value: genre['id'],
                    child: Text(genre['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGenre = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Insira um genero';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (widget.game == null) {
                      Provider.of<GameProvider>(context, listen: false).addGame({
                        'name': _name,
                        'description': _description,
                        'release_date': _releaseDate,
                        'user_id': userId,
                        'genre_id': _selectedGenre,
                      });
                    } else {
                      Provider.of<GameProvider>(context, listen: false).updateGame(widget.game!['id'], {
                        'name': _name,
                        'description': _description,
                        'release_date': _releaseDate,
                        'genre_id': _selectedGenre,
                      });
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.game == null ? 'Add Game' : 'Update Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
