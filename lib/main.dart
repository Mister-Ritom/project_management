import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_management/pages/home_page.dart';
import 'package:project_management/pages/project_page.dart';
import 'package:project_management/pages/sign_in.dart';
import 'package:project_management/pages/starting_page.dart';
import 'package:project_management/pocketbase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.pinkAccent.shade700,
          brightness: Brightness.light,)
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.pinkAccent.shade200,
          brightness: Brightness.dark,)
      ),
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/login': (context) => const SignIn(),
        '/register': (context) => const SignIn(),
        '/project': (context) => const ProjectPage(),
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  final _storage = const FlutterSecureStorage();
  Future<bool> isLoggedIn() async {
    if (PocketbaseGetter.pb.authStore.model!= null) {
      return true;
    }
    final all = await _storage.readAll(
      aOptions: _getAndroidOptions(),
    );
    if (all.isEmpty) {
      return false;
    } else  {
      if (all.containsKey("email")&&all.containsKey("password")) {
        final email = all["email"]!;
        final password = all["password"]!;
        await PocketbaseGetter.pb.collection('users').authWithPassword(email, password);
        return true;
      }
      else {
        return false;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            return const HomePage();
          }
          else {
            return const StartingPage();
          }
        }
        else if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong. Error"));
        }
        else {
          return const Center(child: CircularProgressIndicator());
        }
      }
    );
  }
}
