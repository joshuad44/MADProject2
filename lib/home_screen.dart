import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'interactive_weather_map_screen.dart';
import 'weather_display_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can keep other UI elements if needed
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0, // Adjust the height as needed
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  // Navigate to InteractiveWeatherMapScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractiveWeatherMapScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.map),
              ),
              IconButton(
                onPressed: () {
                  // Navigate to WeatherDisplayScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherDisplayScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.cloud),
              ),
              IconButton(
                onPressed: () {
                  // Navigate to SettingsScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
