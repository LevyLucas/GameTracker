import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Genres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                          return 'Please enter a genre name';
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
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().getGenres(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No genres found'));
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
