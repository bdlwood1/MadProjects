import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductsScreen(),
    ),
  );
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final CollectionReference<Map<String, dynamic>> products = FirebaseFirestore
      .instance
      .collection('products');

  final searchController = TextEditingController();
  final minController = TextEditingController();
  final maxController = TextEditingController();

  String search = '';
  double? minPrice;
  double? maxPrice;

  @override
  void dispose() {
    searchController.dispose();
    minController.dispose();
    maxController.dispose();
    super.dispose();
  }

  void resetFilters() {
    searchController.clear();
    minController.clear();
    maxController.clear();
    setState(() {
      search = '';
      minPrice = null;
      maxPrice = null;
    });
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void applyFilters() {
    final minText = minController.text.trim();
    final maxText = maxController.text.trim();
    final min = minText.isEmpty ? null : double.tryParse(minText);
    final max = maxText.isEmpty ? null : double.tryParse(maxText);

    if ((minText.isNotEmpty && (min == null || !min.isFinite || min < 0)) ||
        (maxText.isNotEmpty && (max == null || !max.isFinite || max < 0))) {
      showMessage('Enter valid nonnegative prices.');
      return;
    }
    if (min != null && max != null && min > max) {
      showMessage('Minimum price cannot exceed maximum.');
      return;
    }

    setState(() {
      search = searchController.text.trim().toLowerCase();
      minPrice = min;
      maxPrice = max;
    });
  }

  Future<void> productForm({
    String? id,
    String initialName = '',
    double? initialPrice,
  }) async {
    final name = TextEditingController(text: initialName);
    final price = TextEditingController(text: initialPrice?.toString() ?? '');
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(id == null ? 'Add Product' : 'Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final productName = name.text.trim();
                      final amount = double.tryParse(price.text.trim());

                      if (productName.isEmpty) {
                        showMessage('Product name is required.');
                        return;
                      }
                      if (amount == null || !amount.isFinite || amount < 0) {
                        showMessage('Enter a valid nonnegative price.');
                        return;
                      }

                      setDialogState(() => saving = true);
                      try {
                        final data = {'name': productName, 'price': amount};
                        if (id == null) {
                          await products.add(data);
                        } else {
                          await products.doc(id).update(data);
                        }
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        showMessage('Product saved.');
                      } catch (e) {
                        showMessage('Save failed: $e');
                        if (dialogContext.mounted) {
                          setDialogState(() => saving = false);
                        }
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    name.dispose();
    price.dispose();
  }

  Future<void> deleteProduct(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Delete "$name"? This cannot be undone.'),
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
      ),
    );

    if (confirmed != true) return;
    try {
      await products.doc(id).delete();
      showMessage('Deleted "$name".');
    } catch (e) {
      showMessage('Delete failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Products'),
        actions: [
          IconButton(
            tooltip: 'Reset filters',
            onPressed: resetFilters,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => productForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() => search = value.trim().toLowerCase());
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Min price',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: maxController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Max price',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton(
                      onPressed: applyFilters,
                      child: const Text('Apply'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: resetFilters,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: products.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final rawPrice = data['price'];
                  final price = rawPrice is num
                      ? rawPrice.toDouble()
                      : double.tryParse(rawPrice.toString());

                  if (!name.contains(search)) return false;
                  if (price == null) return false;
                  if (minPrice != null && price < minPrice!) return false;
                  if (maxPrice != null && price > maxPrice!) return false;
                  return true;
                }).toList();

                docs.sort(
                  (a, b) => (a.data()['name'] ?? '').toString().compareTo(
                    (b.data()['name'] ?? '').toString(),
                  ),
                );

                if (docs.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final name = (data['name'] ?? 'Unnamed').toString();
                    final rawPrice = data['price'];
                    final price = rawPrice is num
                        ? rawPrice.toDouble()
                        : double.tryParse(rawPrice.toString()) ?? 0;

                    return ListTile(
                      title: Text(name),
                      subtitle: Text(
                        '\$${price.toStringAsFixed(2)}\nID: ${doc.id}',
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit),
                            onPressed: () => productForm(
                              id: doc.id,
                              initialName: name,
                              initialPrice: price,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteProduct(doc.id, name),
                          ),
                        ],
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
