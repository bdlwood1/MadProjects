import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

// Handles database operations for folders and cards.
class CatalogueHelper {
  final DatabaseHelper helper;

  CatalogueHelper(this.helper);

  // Reuse the existing SQLite database connection.
  Database get db => helper.database;

  // Adds a new folder.
  Future<int> addFolder(String name) async {
    return await db.insert('folders', {
      'name': name.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Gets all saved folders.
  Future<List<Map<String, dynamic>>> getFolders() async {
    return await db.query('folders', orderBy: 'id ASC');
  }

  // Updates a folder using its ID.
  Future<int> updateFolder(int id, String name) async {
    return await db.update(
      'folders',
      {'name': name.trim()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deletes a folder and its associated cards.
  Future<int> deleteFolder(int id) async {
    return await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  // Adds a new card to a folder.
  Future<int> addCard({
    required String title,
    required String suit,
    required int folderId,
    String notes = '',
    String? imageRef,
  }) async {
    return await db.insert('cards', {
      'title': title.trim(),
      'suit': suit.trim(),
      'notes': notes.trim(),
      'image_ref': imageRef,
      'folder_id': folderId,
    });
  }

  // Gets all cards inside a specific folder.
  Future<List<Map<String, dynamic>>> getCards(int folderId) async {
    return await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'id ASC',
    );
  }

  // Updates an existing card.
  Future<int> updateCard({
    required int id,
    required String title,
    required String suit,
    String notes = '',
    String? imageRef,
  }) async {
    return await db.update(
      'cards',
      {
        'title': title.trim(),
        'suit': suit.trim(),
        'notes': notes.trim(),
        'image_ref': imageRef,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deletes a card using its ID.
  Future<int> deleteCard(int id) async {
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}
