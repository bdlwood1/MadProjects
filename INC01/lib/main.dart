import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 4,
        child: const TabsNonScrollableDemo(),
      ),
    );
  }
}

class TabsNonScrollableDemo extends StatefulWidget {
  const TabsNonScrollableDemo({super.key});

  @override
  State<TabsNonScrollableDemo> createState() => _TabsNonScrollableDemoState();
}

class _TabsNonScrollableDemoState extends State<TabsNonScrollableDemo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4'];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In-Class 01 - Flutter Tabs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [for (final tab in tabs) Tab(text: tab)],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1
          Container(
            color: Colors.amber.shade50,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to Tab 1',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Tab 1'),
                            content: const Text(
                              'This is an AlertDialog from Tab 1.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                ],
              ),
            ),
          ),

          // TAB 2
          Container(
            color: Colors.lightBlue.shade50,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Tab 2 - Image & Text Inputs',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Image.asset(
                    'lib/assets/images/campus.jpg',
                    width: 300,
                    height: 180,
                    fit: BoxFit.cover,
                  ),

                  const SizedBox(height: 20),

                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TAB 3
          Container(
            color: Colors.green.shade50,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Button pressed in Tab 3!'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Click me'),
              ),
            ),
          ),

          // TAB 4
          Container(
            color: Colors.purple.shade50,
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('Item ${index + 1}'),
                    subtitle: const Text('Details displayed inside a Card'),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // BOTTOM APP BAR
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey.shade50,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.home, color: Colors.blueAccent),
              SizedBox(width: 12),
              Text(
                'In-Class 01 • My First Tabs App',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
