import 'package:flutter/material.dart';

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
            // List of available cities and selection
            ElevatedButton(
              onPressed: () {
                // Navigate to city selection screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CitySelectionScreen()),
                );
              },
              child: Text('Select City'),
            ),
            SizedBox(height: 20), // Add spacing between buttons
            // Navigation to other screens
            ElevatedButton(
              onPressed: () {
                // Navigate to other screens
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OtherScreen()),
                );
              },
              child: Text('Navigate to Other Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class CitySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('City Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Implement city selection logic here
          ],
        ),
      ),
    );
  }
}

class OtherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Other Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Implement content for other screen here
          ],
        ),
      ),
    );
  }
}
