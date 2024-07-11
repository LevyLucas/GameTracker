import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../database_helper.dart';

class ManageGenresScreen extends StatefulWidget {
  @override
  _ManageGenresScreenState createState() => _ManageGenresScreenState();
}

class _ManageGenresScreenState extends State<ManageGenresScreen> {
  final _formKey = GlobalKey<FormState>();
  final _genreController = TextEditingController();

  @override
  void dispose() {
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Genres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (userId != null)
              Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _genreController,
                        decoration: InputDecoration(labelText: 'Genre Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira um genero';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await DatabaseHelper().addGenre(_genreController.text);
                          _genreController.clear();
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            if (userId == null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Não pode adicionar generos em modo offline.',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().getGenres(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum genero encontrado'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final genre = snapshot.data![index];
                        return ListTile(
                          title: Text(genre['name']),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
