import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../providers/user_provider.dart';

class AddReviewScreen extends StatefulWidget {
  final Map<String, dynamic>? review;
  final int? gameId;

  AddReviewScreen({this.review, this.gameId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _score;
  late String _description;

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      _score = widget.review!['score'];
      _description = widget.review!['description'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.review == null ? 'Add Review' : 'Edit Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.review != null ? widget.review!['score'].toString() : '',
                decoration: InputDecoration(labelText: 'Score (0-10)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a score';
                  }
                  return null;
                },
                onSaved: (value) => _score = double.parse(value!),
              ),
              TextFormField(
                initialValue: widget.review != null ? widget.review!['description'] : '',
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (widget.review == null) {
                      Provider.of<ReviewProvider>(context, listen: false).addReview({
                        'score': _score,
                        'description': _description,
                        'date': DateTime.now().toIso8601String(),
                        'user_id': userId,
                        'game_id': widget.gameId,
                      });
                    } else {
                      Provider.of<ReviewProvider>(context, listen: false).updateReview(widget.review!['id'], {
                        'score': _score,
                        'description': _description,
                        'date': DateTime.now().toIso8601String(),
                      });
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.review == null ? 'Add Review' : 'Update Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
