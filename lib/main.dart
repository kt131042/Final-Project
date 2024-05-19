import 'package:flutter/material.dart';
import 'package:jittirat/screen/custumer.dart';
import 'package:jittirat/screen/dashboard.dart';
import 'package:jittirat/screen/room.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
//ไหนอะ
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
        length: 3,
        child: Scaffold(
          body: TabBarView(
            children: [
              Dashboard(),
              Room(),
              Custumer(),
            ],
          ),
          backgroundColor: Colors.pinkAccent,
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.dashboard),
              ),
              Tab(
                icon: Icon(Icons.bedroom_parent),
              ),
              Tab(
                icon: Icon(Icons.people_alt),
              )
            ],
          ),
        ));
  }
}
