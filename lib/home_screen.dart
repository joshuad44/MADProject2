import 'package:flutter/material.dart';
import 'package:project_2/consts.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import 'settings_screen.dart';
import 'interactive_weather_map_screen.dart';
import 'weather_display_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen  extends State {
  // Define a list of cities for which you want to display weather information
  List<String> cities = ['Atlanta', 'New York', 'London', 'Tokyo'];
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

  IconData mapWeatherConditionToIcon(Weather weather) {
    switch (weather.weatherIcon) {
      case '11d':
        return WeatherIcons.day_thunderstorm;
      case '01d':
        return WeatherIcons.day_sunny;
      case '01n':
        return WeatherIcons.night_clear;
      case '02d':
        return WeatherIcons.day_cloudy;
      case '02n':
        return WeatherIcons.night_cloudy;
      case '03d':
        return WeatherIcons.cloud;
      case '03n':
        return WeatherIcons.cloud;
      case '04d':
        return WeatherIcons.cloudy;
      case '04n':
        return WeatherIcons.cloudy;
      case '09d':
        return WeatherIcons.showers;
      case '09n':
        return WeatherIcons.showers;
      case '10d':
        return WeatherIcons.day_rain;
      case '10n':
        return WeatherIcons.night_rain;
      case '11d':
        return WeatherIcons.thunderstorm;
      case '11n':
        return WeatherIcons.thunderstorm;
      case '13d':
        return WeatherIcons.snow;
      case '13n':
        return WeatherIcons.snow;
      case '50d':
        return WeatherIcons.fog;
      case '50n':
        return WeatherIcons.fog;
      default:
        return WeatherIcons.na;
    }
  }

  Widget contentFinishedDownload(Map<String, dynamic> data) {
    Weather weather = data['weather'];
    String city = data['city'];
    // Retrieve weather information
    String weatherCondition = weather.weatherMain ?? 'Unknown';
    double temperature = weather.temperature?.celsius ?? 0.0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
              ],
            ),
            Row(
              children: [
                Icon(
                  size: 75,
                  mapWeatherConditionToIcon(weather)
                ), 
                SizedBox(width: 20,) 
              ],
            ),
          ],
        ),
      ),
    );
  }
}
