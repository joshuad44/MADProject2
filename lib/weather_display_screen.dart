import 'package:flutter/material.dart';

class WeatherDisplayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dynamic weather display based on weather, city, and time of day
            Text(
              'City: New York', // Placeholder city name
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              'Weather: Sunny', // Placeholder weather condition
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Temperature: 25°C', // Placeholder temperature
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Hourly forecast
            Text(
              'Hourly Forecast:', // Placeholder hourly forecast
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('12:00 PM - 25°C'),
                Text('01:00 PM - 26°C'),
                Text('02:00 PM - 27°C'),
                // Add more hourly forecast data here as needed
              ],
            ),
            SizedBox(height: 20),
            // Weekly forecast
            Text(
              'Weekly Forecast:', // Placeholder weekly forecast
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                ListTile(
                  title: Text('Monday - Sunny'),
                  subtitle: Text('High: 28°C, Low: 20°C'),
                ),
                ListTile(
                  title: Text('Tuesday - Cloudy'),
                  subtitle: Text('High: 26°C, Low: 18°C'),
                ),
                // Add more weekly forecast data here as needed
              ],
            ),
          ],
        ),
      ),
    );
  }
}
