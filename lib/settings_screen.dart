import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom notifications setup
            ElevatedButton(
              onPressed: () {
                // Navigate to custom notifications setup screen
              },
              child: Text('Custom Notifications Setup'),
            ),
            SizedBox(height: 20), // Add spacing between buttons
            // Weather card backgrounds customization
            ElevatedButton(
              onPressed: () {
                // Navigate to weather card backgrounds customization screen
              },
              child: Text('Weather Card Backgrounds Customization'),
            ),
            SizedBox(height: 20), // Add spacing between buttons
            // Default geographic area settings
            ElevatedButton(
              onPressed: () {
                // Navigate to default geographic area settings screen
              },
              child: Text('Default Geographic Area Settings'),
            ),
            SizedBox(height: 20), // Add spacing between buttons
            // Account settings
            ElevatedButton(
              onPressed: () {
                // Navigate to account settings screen
              },
              child: Text('Account Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
