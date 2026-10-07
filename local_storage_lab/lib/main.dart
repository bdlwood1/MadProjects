import 'package:flutter/material.dart';

import 'database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final helper = DatabaseHelper();

  try {
    await helper.init();
  } catch (error, stackTrace) {
    debugPrint('Database initialization failed: $error\n$stackTrace');

    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Could not open local storage. Restart the app and check the logs.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  runApp(DirectoryApp(helper: helper));
}

class DirectoryApp extends StatelessWidget {
  const DirectoryApp({super.key, required this.helper});

  final DatabaseHelper helper;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fall Festival Roster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: RosterPage(helper: helper),
    );
  }
}

class RosterPage extends StatefulWidget {
  const RosterPage({super.key, required this.helper});

  final DatabaseHelper helper;

  @override
  State<RosterPage> createState() => _RosterPageState();
}

class _RosterPageState extends State<RosterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  List<Map<String, dynamic>> _rows = [];
  int _count = 0;
  int? _selectedId;

  bool _loading = true;
  bool _busy = false;
  String? _errorMessage;

  bool get _editing => _selectedId != null;

  @override
  void initState() {
    super.initState();
    _loadRows();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadRows() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final rows = await widget.helper.queryAllRows();
      final count = await widget.helper.queryRowCount();

      if (!mounted) return;

      setState(() {
        _rows = rows;
        _count = count;
        _loading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Refresh failed: $error\n$stackTrace');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = 'Could not load the roster. Tap Refresh to try again.';
      });
    }
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Enter a name.';
    }

    return null;
  }

  String? _validateAge(String? value) {
    final text = value?.trim() ?? '';
    final age = int.tryParse(text);

    if (text.isEmpty) {
      return 'Enter an age.';
    }

    if (age == null) {
      return 'Age must be a whole number.';
    }

    if (age < 0 || age > 130) {
      return 'Age must be from 0 through 130.';
    }

    return null;
  }

  Future<void> _save() async {
    if (_busy) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final age = int.parse(_ageController.text.trim());

    setState(() {
      _busy = true;
    });

    bool writeSucceeded = false;

    try {
      int affected;

      if (_editing) {
        affected = await widget.helper.update({
          DatabaseHelper.columnId: _selectedId,
          DatabaseHelper.columnName: name,
          DatabaseHelper.columnAge: age,
        });
      } else {
        await widget.helper.insert({
          DatabaseHelper.columnName: name,
          DatabaseHelper.columnAge: age,
        });

        affected = 1;
      }

      if (!mounted) return;

      if (affected == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record not found. Refreshing the roster.'),
          ),
        );
        await _loadRows();
        return;
      }

      writeSucceeded = true;
      _clearForm();

      try {
        final rows = await widget.helper.queryAllRows();
        final count = await widget.helper.queryRowCount();

        if (!mounted) return;

        setState(() {
          _rows = rows;
          _count = count;
          _loading = false;
          _errorMessage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editing ? 'Guest updated.' : 'Guest saved.')),
        );
      } catch (error, stackTrace) {
        debugPrint('Refresh after save failed: $error\n$stackTrace');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved, but refresh failed. Tap Refresh.'),
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Save failed: $error\n$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            writeSucceeded
                ? 'Saved, but refresh failed. Tap Refresh.'
                : 'Could not save the guest. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _startEdit(Map<String, dynamic> row) {
    if (_busy) return;

    setState(() {
      _selectedId = row[DatabaseHelper.columnId] as int;
      _nameController.text = row[DatabaseHelper.columnName].toString();
      _ageController.text = row[DatabaseHelper.columnAge].toString();
    });
  }

  void _clearForm() {
    _selectedId = null;
    _nameController.clear();
    _ageController.clear();
    _formKey.currentState?.reset();
  }

  void _cancelEdit() {
    if (_busy) return;

    setState(() {
      _clearForm();
    });
  }

  Future<void> _deleteRow(Map<String, dynamic> row) async {
    if (_busy) return;

    final id = row[DatabaseHelper.columnId] as int;
    final name = row[DatabaseHelper.columnName].toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete guest?'),
          content: Text('Delete ID $id, $name?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _busy = true;
    });

    try {
      final affected = await widget.helper.delete(id);

      if (!mounted) return;

      if (affected == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record not found. Refreshing the roster.'),
          ),
        );
      } else {
        if (_selectedId == id) {
          _clearForm();
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Guest deleted.')));
      }

      await _loadRows();
    } catch (error, stackTrace) {
      debugPrint('Delete failed: $error\n$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete the guest. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fall Festival Roster'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _loadRows,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      enabled: !_busy,
                      decoration: const InputDecoration(
                        labelText: 'Guest name',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      enabled: !_busy,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateAge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _busy ? null : _save,
                            child: Text(_editing ? 'Save' : 'Add'),
                          ),
                        ),
                        if (_editing) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _busy ? null : _cancelEdit,
                              child: const Text('Cancel Edit'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Record count: $_count',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _busy ? null : _loadRows,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const Divider(),
              Expanded(child: _buildRoster()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoster() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : _loadRows,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_rows.isEmpty) {
      return const Center(child: Text('No festival guests yet.'));
    }

    return ListView.separated(
      itemCount: _rows.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final row = _rows[index];

        final id = row[DatabaseHelper.columnId];
        final name = row[DatabaseHelper.columnName];
        final age = row[DatabaseHelper.columnAge];

        return ListTile(
          title: Text('$name'),
          subtitle: Text('ID: $id • Age: $age'),
          trailing: Wrap(
            spacing: 4,
            children: [
              IconButton(
                onPressed: _busy ? null : () => _startEdit(row),
                tooltip: 'Edit',
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: _busy ? null : () => _deleteRow(row),
                tooltip: 'Delete',
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        );
      },
    );
  }
}
