import 'package:flutter/material.dart';
import 'package:project_2/consts.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import 'settings_screen.dart';
import 'interactive_weather_map_screen.dart';
import 'weather_display_screen.dart';

class HomeDisplayScreen extends StatefulWidget {
  @override
  _HomeDisplaScreen createState() => _HomeDisplaScreen();
}

class _HomeDisplaScreen  extends State {
  // Define a list of cities for which you want to display weather information
  List<String> cities = ['atlanta', 'new york', 'london', 'tokyo'];
  WeatherFactory ws = new WeatherFactory(OPENWEATHER_API_KEY);
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    print('Initializing WeatherDisplayScreen');
    // Fetch weather data for all cities as soon as the page loads
    queryWeatherForCities();
  }

  void queryWeatherForCities() async {
    List<Map<String, dynamic>> newData = [];
    for (String city in cities) {
      Weather weather = await ws.currentWeatherByCityName(city);
      newData.add({
        'city': city,
        'weather': weather,
      });
    }
    setState(() {
      _data = newData;
      _isLoading = false; // Set loading state to false after data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/home_screen');
            },
          ),
        ),
        body: _isLoading
            ? contentNotDownloaded()
            : ListView.builder(
                itemCount: _data.length,
                itemBuilder: (BuildContext context, int index) {
                  return contentFinishedDownload(_data[index]);
                },
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
      ),
    );
  }
  Widget contentNotDownloaded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Downloading weather data...',
          ),
        ],
      ),
    );
  }

  Widget contentFinishedDownload(Map<String, dynamic> data) {
    Weather weather = data['weather'];
    String city = data['city'];
    // Retrieve weather information
    String weatherCondition = weather.weatherMain ?? 'Unknown';
    String weatherIcon = weather.weatherIcon ?? 'na';
    double temperature = weather.temperature?.celsius ?? 0.0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City: $city',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Weather: $weatherCondition',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Temperature: ${temperature.toStringAsFixed(1)}°C',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Hourly Forecast:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Add hourly forecast widgets here if needed
          ],
        ),
      ),
    );
  }
}
