import 'package:flutter/material.dart';
import 'package:project_2/consts.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import 'settings_screen.dart';
import 'interactive_weather_map_screen.dart';
import 'weather_display_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State
{
  // Define a TextEditingController for the input field
  String? defaultCity = '';
  String? defaultBackground = '';
  List<String> cities = [];
  WeatherFactory ws = new WeatherFactory(OPENWEATHER_API_KEY);
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true; 
  TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('Initializing WeatherDisplayScreen');
    // Fetch weather data for all cities as soon as the page loads
    fetchUserCities();
  }

  void fetchUserCities() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userSnapshot.exists) {
          String? userCity = userSnapshot['city'];
          String? userBackground = userSnapshot['backgroundImage'];
          List<String?> userCities = List<String?>.from(userSnapshot['cities']);
          userCities.removeWhere((city) => city == null);
          if (userCity != null && userCities.isNotEmpty) {
            setState(() {
              cities = userCities.cast<String>();
              defaultBackground = userBackground;
              defaultCity = userCity;
            });
            queryWeatherForCities();
            }
          } else {
            print('User info not found in document');
          }
        } else {
          print('User ID not found');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  void queryWeatherForCities() async {
    List<Map<String, dynamic>> newData = [];
    for (String city in cities) {
      Weather weather = await ws.currentWeatherByCityName(city);
      newData.add({
        'city': city,
        'weather': weather,
        'background': defaultBackground,
      });
    }
    setState(() {
      _data = newData;
      _isLoading = false; // Set loading state to false after data is fetched
    });
  }

  void addCity() async {
    String newCity = _cityController.text.trim();
    if (newCity.isNotEmpty && !cities.contains(newCity)) {
      Weather? weather = await ws.currentWeatherByCityName(newCity);
      if (weather != null) {
        setState(() {
          cities.add(newCity);
          _cityController.clear();
        });
        await saveCitiesToFirebase();
        queryWeatherForCities();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
          title: Text('Invalid City'),
          content: Text('The city you entered is not valid.'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
           ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Duplicate City'),
          content: Text('The city you entered is already in the list.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> saveCitiesToFirebase() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({'cities': cities,});
        print('Cities saved to Firebase');
      }
    } catch (e) {
      print('Error saving cities to Firebase: $e');
    }
  }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
        ? contentNotDownloaded()
        : ListView.builder(
        itemCount: _data.length,
        itemBuilder: (BuildContext context, int index) {
          return contentFinishedDownload(_data[index], index);
        },
      ),
      backgroundColor: Colors.black87,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
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
                color: Colors.blue,
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
                color: Colors.blue,
              ),
              IconButton(
                onPressed: () {
                  // Navigate to SettingsScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(),
                    ),
                  );
                },
                icon: Icon(Icons.settings),
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Add City'),
              content: TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'Enter City Name'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    addCity();
                    Navigator.pop(context);
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
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

    Image mapWeatherConditionToBackground(Weather weather) {
      switch (weather.weatherIcon) {
        case '01d':
          return Image(image: AssetImage('assets/day_sunny.jpeg'));
        case '01n':
          return Image(image: AssetImage('assets/night_clear.jpeg'));
        case '02d':
          return Image(image: AssetImage('assets/cloudy2.jpeg'));
        case '02n':
          return Image(image: AssetImage('assets/cloudy2.jpeg'));
        case '03d':
          return Image(image: AssetImage('assets/cloudy2.jpeg'));
        case '03n':
          return Image(image: AssetImage('assets/cloudy2.jpeg'));
        case '04d':
          return Image(image: AssetImage('assets/cloudy3.jpeg'));
        case '04n':
          return Image(image: AssetImage('assets/cloudy3.jpeg'));
        case '09d':
          return Image(image: AssetImage('assets/day_showers.jpeg'));
        case '09n':
          return Image(image: AssetImage('assets/night_showers.jpeg'));
        case '10d':
          return Image(image: AssetImage('assets/day_rain.jpeg'));
        case '10n':
          return Image(image: AssetImage('assets/night_rain.jpeg'));
        case '11d':
          return Image(image: AssetImage('assets/day_thunderstorm.jpeg'));
        case '11n':
          return Image(image: AssetImage('assets/night_thunderstorm.jpeg'));
        case '13d':
          return Image(image: AssetImage('assets/snow_day.jpeg'));
        case '13n':
          return Image(image: AssetImage('assets/snow_night.jpeg'));
        case '50d':
          return Image(image: AssetImage('assets/day_fog.png'));
        case '50n':
          return Image(image: AssetImage('assets/night_fog.png'));
        default:
          return Image(image: AssetImage('assets/day_sunny.jpeg'));
      }
    }

  Widget contentFinishedDownload(Map<String, dynamic> data, int index) {
    Weather weather = data['weather'];
    String city = data['city'];
    String weatherCondition = weather.weatherMain ?? 'Unknown';
    double temperature = weather.temperature?.celsius ?? 0.0;
    Image backgroundImage;

    if (defaultBackground != '') {
      backgroundImage = mapWeatherConditionToBackground(weather);
    } else {
      backgroundImage = Image(image: AssetImage('assets/day_sunny.jpeg')); // Assuming your defaultBackground is a URL
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: backgroundImage.image,
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City: $city',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Weather: $weatherCondition',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Temperature: ${temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(fontSize: 18, color: Colors.white, shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    iconSize: 50,
                    color: Colors.white,
                    onPressed: () {
                      removeCity(index);
                    },
                  ),
                ],
              ),
              Icon(
                size: 75,
                mapWeatherConditionToIcon(weather),
                color: Colors.white,
                shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
              ),
              SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }

  void removeCity(int index) async {
    setState(() {
      cities.removeAt(index);
      _data.removeAt(index);
    });
    await saveCitiesToFirebase();
    queryWeatherForCities(); // Re-fetch weather data after city removal
  }

}