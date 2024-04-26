import 'package:flutter/material.dart';
import 'package:project_2/consts.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherDisplayScreen extends StatefulWidget {
  @override
  _WeatherDisplayScreen createState() => _WeatherDisplayScreen();
}

class _WeatherDisplayScreen extends State {
  WeatherFactory ws = new WeatherFactory(OPENWEATHER_API_KEY);
  List <Weather> _data = [];
  List<Map<String, dynamic>> _weeklyForecast = [];
  List<Map<String, dynamic>> _hourlyForecast = [];
  bool _isLoading = true; // Flag to track loading state

  @override
  void initState() {
    super.initState();
    print('Initializing WeatherDisplayScreen');
    // Fetch weather and forecast data as soon as the page loads
    queryWeather();
    queryHourlyForecasts();
    queryForecast();
  }
  String _getWeekdayName(int? weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  void queryForecast() async {

    List<Weather> forecasts = await ws.fiveDayForecastByCityName('atlanta');
    setState(() {
      _data = forecasts;
      _weeklyForecast = []; // Clear previous forecast data
      Set<String> uniqueDays = Set(); // Create a set to store unique days
      for (var forecast in forecasts) {
        String day = forecast.date?.weekday != null
            ? _getWeekdayName(forecast.date?.weekday)
            : 'Unknown';
        if (!uniqueDays.contains(day)) { // Check if the day has already been added
          String condition = forecast.weatherMain ?? 'Unknown';
          String high = forecast.tempMax?.celsius?.toStringAsFixed(1) ?? 'Unknown';
          String low = forecast.tempMin?.celsius?.toStringAsFixed(1) ?? 'Unknown';
          _weeklyForecast.add({
            'day': day,
            'condition': condition,
            'high': '$high°C',
            'low': '$low°C',
          });
          uniqueDays.add(day); // Add the day to the set to mark it as added
        }
      }
      _isLoading = false; // Set loading state to false after data is fetched
    });
  }

  void queryHourlyForecasts() async {
    // Fetch the most recent 8 three-hour forecasts (covering 24 hours)
    List<Weather> hourlyForecasts = await ws.fiveDayForecastByCityName('atlanta');
    setState(() {
      _hourlyForecast = []; // Clear previous hourly forecast data
      for (int i = 0; i < hourlyForecasts.length && i < 8; i++) {
        Weather forecast = hourlyForecasts[i];
        String time = forecast.date?.hour != null
            ? _formatTime(forecast.date!.hour) // Format time as HH:00 AM/PM
            : 'Unknown';
        Weather weather = forecast;
        String temperature = forecast.temperature?.celsius != null
            ? '${forecast.temperature!.celsius!.toStringAsFixed(1)}°C'
            : 'Unknown';
        _hourlyForecast.add({
          'time': time,
          'weather': weather,
          'temperature': temperature,
        });
      }
    });
  }

  String _formatTime(int hour) {
    if (hour == 0) {
      return '12:00 AM';
    } else if (hour < 12) {
      return '$hour:00 AM';
    } else if (hour == 12) {
      return '12:00 PM';
    } else {
      return '${hour - 12}:00 PM';
    }
  }


  void queryWeather() async {
    Weather weather = await ws.currentWeatherByCityName('atlanta');
    setState(() {
      _data = [weather];
      _isLoading = false; // Set loading state to false after data is fetched
    });
  }


  Widget contentFinishedDownload() {
  if (_data.isEmpty) {
    return contentNotDownloaded();
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


  Weather weather = _data.first;
  String city = weather.areaName ?? 'Unknown';
  String weatherCondition = weather.weatherMain ?? 'Unknown';
  double temperature = weather.temperature?.celsius ?? 0.0;
  List<Map<String, dynamic>> hourlyForecast = _hourlyForecast; // Replace with actual hourly forecast data
  List<Map<String, dynamic>> weeklyForecast = _weeklyForecast;

  return Center(
    child: SingleChildScrollView(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                          size: 80,
                          mapWeatherConditionToIcon(weather)
                      ), 
                      SizedBox(width: 50,) 
                    ],
                  ),
                ]
              ),
              SizedBox(height: 20),
              Text(
                'Hourly Forecast:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var hourForecast in hourlyForecast)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('${hourForecast['time']}'),
                            SizedBox(height: 10),
                            Icon(
                              size: 40,
                              mapWeatherConditionToIcon(hourForecast['weather'])
                            ), 
                            SizedBox(height: 10),
                            Text('${hourForecast['temperature']}'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '5-Day Forecast:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  for (int i = 1; i < weeklyForecast.length; i++)
                    ListTile(
                      title: Text('${weeklyForecast[i]['day']} - ${weeklyForecast[i]['condition']}'),
                      subtitle: Text('High: ${weeklyForecast[i]['high']}, Low: ${weeklyForecast[i]['low']}'),
                    ),
                ],
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather App'),
          leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/home_screen');
          },
        ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: _isLoading ? contentNotDownloaded() : contentFinishedDownload(), // Display appropriate content based on loading state
            )
          ],
        ),
      ),
    );
  }
}
