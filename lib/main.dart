import 'package:flutter/material.dart';
import 'package:project_2/placeholder.dart';

// Importing other dart files
import 'settings_screen.dart';
import 'home_screen.dart';
import 'interactive_weather_map_screen.dart';
import 'sign_in_screen.dart';
import 'weather_display_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/settings': (context) => SettingsScreen(),
        '/interactive_weather_map': (context) => InteractiveWeatherMapScreen(),
        '/sign_in': (context) => SignInScreen(),
        '/weather_display': (context) => WeatherDisplayScreen(),
      },
    );
  }
}
