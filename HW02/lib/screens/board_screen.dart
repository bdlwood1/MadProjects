import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../services/board_service.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final composer = TextEditingController();

  late final boardStream = boardService.messageBoard();

  bool posting = false;
  String? pendingId;

  // Display feedback for database operations.
  void notify(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Prevent repeated submissions while posting.
  Future<void> post() async {
    if (posting) return;

    final text = composer.text.trim();

    if (text.isEmpty || text.length > 500) {
      notify('Enter a message between 1 and 500 characters.');
      return;
    }

    setState(() => posting = true);
    pendingId ??= boardService.newMessageId();

    try {
      await boardService.postMessage(text, pendingId!);
      if (!mounted) return;

      composer.clear();
      pendingId = null;
      notify('Message posted successfully.');
    } catch (_) {
      notify('Unable to post. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => posting = false);
    }
  }

  // Open a dialog to edit an owned message.
  Future<void> edit(String id, String oldText) async {
    String newText = oldText;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextFormField(
          initialValue: oldText,
          maxLength: 500,
          onChanged: (value) => newText = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, newText.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (result.isEmpty || result.length > 500) {
      notify('Enter 1 to 500 characters.');
      return;
    }

    try {
      await boardService.editMessage(id, result);
      notify('Message updated.');
    } catch (_) {
      notify('Edit failed. Check permissions or connection.');
    }
  }

  // Confirm before deleting a message.
  Future<void> remove(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await boardService.deleteMessage(id);
      notify('Message deleted.');
    } catch (_) {
      notify('Delete failed. Check permissions or connection.');
    }
  }

  @override
  void dispose() {
    composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Connect'),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF172554),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.displayName ?? "Student"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Community Message Board',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: composer,
                  enabled: !posting,
                  maxLength: 500,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Share something with the community...',
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: posting ? null : post,
                    icon: const Icon(Icons.send),
                    label: Text(posting ? 'Posting...' : 'Post Message'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            // Automatically rebuild when Firestore changes.
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: boardStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Unable to load messages.'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60),
                        SizedBox(height: 12),
                        Text('No messages yet.'),
                        Text('Be the first to post!'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final data = doc.data();
                    final owned = data['authorUid'] == user?.uid;
                    final timestamp = data['createdAt'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(child: Icon(Icons.person)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    data['authorName'] ?? 'User',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (owned)
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        edit(doc.id, data['text'] ?? ''),
                                  ),
                                if (owned)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => remove(doc.id),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              data['text'] ?? '',
                              style: const TextStyle(fontSize: 17),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              doc.metadata.hasPendingWrites
                                  ? 'Pending sync'
                                  : timestamp is Timestamp
                                  ? timestamp
                                        .toDate()
                                        .toLocal()
                                        .toString()
                                        .split('.')[0]
                                  : 'Waiting for server timestamp',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (data['editedAt'] != null)
                              const Text(
                                'Edited',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
