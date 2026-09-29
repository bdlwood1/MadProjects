// Model class used to store information about each movie.
class Movie {
  final String title;
  final String posterPath;
  final List<String> cast;
  final String synopsis;

  Movie({
    required this.title,
    required this.posterPath,
    required this.cast,
    required this.synopsis,
  });
}
