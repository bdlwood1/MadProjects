import 'package:flutter/material.dart';

import '../data/movies_data.dart';
import 'details_screen.dart';

// HomeScreen displays all of the movies in a scrollable list.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Watchlist'), centerTitle: true),

      // ListView.builder creates a scrollable list from our movie data.
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sampleMovies.length,
        itemBuilder: (context, index) {
          final movie = sampleMovies[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),

              // The movie title is displayed for each item.
              title: Text(
                movie.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text('Tap to view details'),
              trailing: const Icon(Icons.chevron_right),

              // Tapping a movie opens DetailsScreen and passes
              // the complete Movie object to the next screen.
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(movie: movie),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
