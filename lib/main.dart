import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/habit_screen.dart';
import 'package:habit_tracker/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers:
    [
      ChangeNotifierProvider(create: (context) => HabitProvider(),)
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Trackers',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(future: Provider.of<HabitProvider>(context, listen: false).loadHabits()
          , builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.done) {
          return SplashScreen();
        } else {
          return HabitScreen();
        }
      }


    ),
    );
  }
}