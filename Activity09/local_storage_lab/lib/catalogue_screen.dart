import 'package:flutter/material.dart';

import 'catalogue_helper.dart';
import 'database_helper.dart';

class CatalogueScreen extends StatefulWidget {
  final DatabaseHelper helper;

  const CatalogueScreen({super.key, required this.helper});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  late final CatalogueHelper catalogue;
  List<Map<String, dynamic>> folders = [];
  List<Map<String, dynamic>> cards = [];
  int? selectedFolderId;
  String selectedFolderName = '';
  bool loading = true;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    catalogue = CatalogueHelper(widget.helper);
    loadFolders();
  }

  Future<void> loadFolders() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await catalogue.getFolders();
      if (!mounted) return;
      setState(() => folders = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Could not load folders: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> loadCards() async {
    final folderId = selectedFolderId;
    if (folderId == null || !mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await catalogue.getCards(folderId);
      if (!mounted || selectedFolderId != folderId) return;
      setState(() => cards = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Could not load cards: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> askFolderName({Map<String, dynamic>? folder}) async {
    final initialName = folder?['name']?.toString() ?? '';

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String name = initialName;

        return AlertDialog(
          title: Text(folder == null ? 'Add Folder' : 'Edit Folder'),
          content: TextFormField(
            initialValue: initialName,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Folder name'),
            onChanged: (value) => name = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, name.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> folderForm({Map<String, dynamic>? folder}) async {
    if (busy) return;

    final name = await askFolderName(folder: folder);

    if (!mounted || name == null) return;

    if (name.isEmpty) {
      showMessage('Enter a folder name.');
      return;
    }

    setState(() => busy = true);

    try {
      if (folder == null) {
        final id = await catalogue.addFolder(name);
        if (!mounted) return;
        showMessage('Folder added: ID $id');
      } else {
        final count = await catalogue.updateFolder(folder['id'] as int, name);
        if (!mounted) return;
        showMessage('$count folder updated.');
      }

      await loadFolders();
    } catch (e) {
      showMessage('Could not save folder: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<bool> confirmDelete(String label) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete $label?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> deleteFolder(Map<String, dynamic> folder) async {
    if (busy) return;

    final id = folder['id'] as int;

    final confirmed = await confirmDelete(
      'folder "${folder['name']}" and all its cards',
    );

    if (!mounted || !confirmed) return;

    setState(() => busy = true);

    try {
      final count = await catalogue.deleteFolder(id);
      if (!mounted) return;
      showMessage('$count folder deleted.');
      await loadFolders();
    } catch (e) {
      showMessage('Could not delete folder: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<List<String>?> askCardDetails({Map<String, dynamic>? card}) async {
    final initialTitle = card?['title']?.toString() ?? '';
    final initialSuit = card?['suit']?.toString() ?? '';
    final initialNotes = card?['notes']?.toString() ?? '';
    final initialImage = card?['image_ref']?.toString() ?? '';

    return showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        String title = initialTitle;
        String suit = initialSuit;
        String notes = initialNotes;
        String image = initialImage;

        return AlertDialog(
          title: Text(card == null ? 'Add Card' : 'Edit Card'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: initialTitle,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (value) => title = value,
                ),
                TextFormField(
                  initialValue: initialSuit,
                  decoration: const InputDecoration(labelText: 'Suit'),
                  onChanged: (value) => suit = value,
                ),
                TextFormField(
                  initialValue: initialNotes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  onChanged: (value) => notes = value,
                ),
                TextFormField(
                  initialValue: initialImage,
                  decoration: const InputDecoration(
                    labelText: 'Image reference (optional)',
                  ),
                  onChanged: (value) => image = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, [
                  title.trim(),
                  suit.trim(),
                  notes.trim(),
                  image.trim(),
                ]);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> cardForm({Map<String, dynamic>? card}) async {
    if (busy || selectedFolderId == null) return;

    final folderId = selectedFolderId!;
    final values = await askCardDetails(card: card);

    if (!mounted || values == null) return;
    if (selectedFolderId != folderId) return;

    if (values[0].isEmpty || values[1].isEmpty) {
      showMessage('Title and suit are required.');
      return;
    }

    setState(() => busy = true);

    try {
      if (card == null) {
        final id = await catalogue.addCard(
          title: values[0],
          suit: values[1],
          folderId: folderId,
          notes: values[2],
          imageRef: values[3].isEmpty ? null : values[3],
        );

        if (!mounted) return;
        showMessage('Card added: ID $id');
      } else {
        final count = await catalogue.updateCard(
          id: card['id'] as int,
          title: values[0],
          suit: values[1],
          notes: values[2],
          imageRef: values[3].isEmpty ? null : values[3],
        );

        if (!mounted) return;
        showMessage('$count card updated.');
      }

      await loadCards();
    } catch (e) {
      showMessage('Could not save card: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> deleteCard(Map<String, dynamic> card) async {
    if (busy) return;

    final confirmed = await confirmDelete('card "${card['title']}"');

    if (!mounted || !confirmed) return;

    setState(() => busy = true);

    try {
      final count = await catalogue.deleteCard(card['id'] as int);

      if (!mounted) return;
      showMessage('$count card deleted.');
      await loadCards();
    } catch (e) {
      showMessage('Could not delete card: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final insideFolder = selectedFolderId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(insideFolder ? selectedFolderName : 'Card Catalogue'),
        leading: insideFolder
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: busy
                    ? null
                    : () {
                        setState(() {
                          selectedFolderId = null;
                          selectedFolderName = '';
                          cards = [];
                          loading = false;
                          error = null;
                        });
                        loadFolders();
                      },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: busy
                ? null
                : insideFolder
                ? loadCards
                : loadFolders,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: busy
            ? null
            : () {
                if (insideFolder) {
                  cardForm();
                } else {
                  folderForm();
                }
              },
        icon: const Icon(Icons.add),
        label: Text(insideFolder ? 'Add Card' : 'Add Folder'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!),
                  TextButton(
                    onPressed: insideFolder ? loadCards : loadFolders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : insideFolder
          ? buildCards()
          : buildFolders(),
    );
  }

  Widget buildFolders() {
    if (folders.isEmpty) {
      return const Center(child: Text('No folders yet. Tap Add Folder.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];

        return ListTile(
          leading: const Icon(Icons.folder),
          title: Text(folder['name'].toString()),
          subtitle: Text('Folder ID: ${folder['id']}'),
          onTap: busy
              ? null
              : () {
                  setState(() {
                    selectedFolderId = folder['id'] as int;
                    selectedFolderName = folder['name'].toString();
                    cards = [];
                  });
                  loadCards();
                },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: busy ? null : () => folderForm(folder: folder),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: busy ? null : () => deleteFolder(folder),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCards() {
    if (cards.isEmpty) {
      return const Center(child: Text('No cards yet. Tap Add Card.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: ListTile(
            title: Text(card['title'].toString()),
            subtitle: Text(
              'ID: ${card['id']} | Suit: ${card['suit']}\n'
              'Notes: ${card['notes'] ?? ''}\n'
              'Image: ${card['image_ref'] ?? 'None'}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: busy ? null : () => cardForm(card: card),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: busy ? null : () => deleteCard(card),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
