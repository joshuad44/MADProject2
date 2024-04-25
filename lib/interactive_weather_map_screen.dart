import 'package:flutter/material.dart';

class InteractiveWeatherMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Weather Map'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Interactive radar weather map with navigation and search features
            ElevatedButton(
              onPressed: () {
                // Navigate to full-screen interactive radar weather map
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FullScreenWeatherMap()),
                );
              },
              child: Text('Open Radar Map'),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenWeatherMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Weather Map'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Full-screen interactive radar weather map
            // Implement radar map here, you might use a web view or a custom widget
            Text('Full Screen Weather Map'),
          ],
        ),
      ),
    );
  }
}
