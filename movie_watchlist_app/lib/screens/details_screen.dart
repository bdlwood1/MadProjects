import 'package:flutter/material.dart';

import '../models/movie.dart';

// DetailsScreen displays all of the information for the selected movie.
class DetailsScreen extends StatelessWidget {
  final Movie movie;

  const DetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displays the movie poster.
            Center(
              child: Image.asset(
                movie.posterPath,
                height: 400,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Displays the movie title.
            Text(
              movie.title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Displays the cast members.
            const Text(
              'Cast',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(movie.cast.join(', ')),

            const SizedBox(height: 16),

            // Displays the movie synopsis.
            const Text(
              'Synopsis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(movie.synopsis),
          ],
        ),
      ),
    );
  }
}
