import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project_2/consts.dart';
import 'dart:convert';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import 'settings_screen.dart';
import 'interactive_weather_map_screen.dart';
import 'weather_display_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String customMapStyleJson = '''
[
  {
    "featureType": "all",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "all",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  }
]
''';


var customMapStyle = jsonDecode(customMapStyleJson);

class CityWeather {
  final String city;
  Weather? weather; // Make weather nullable

  LatLng? latLng;

  CityWeather({
    required this.city,
  });

  Future<void> fetchCoordinatesAndWeather(WeatherFactory ws) async {
    await fetchCoordinates();
    weather = await ws.currentWeatherByCityName(city);
  }

  Future<void> fetchCoordinates() async {
    final apiKey = 'AIzaSyAQeHSeTN6iqdezyleUpLJN0fQvuUIQlL4';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$city&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    final results = data['results'];

    if (results != null && results.length > 0) {
      final location = results[0]['geometry']['location'];
      final lat = location['lat'];
      final lng = location['lng'];
      latLng = LatLng(lat, lng);
    }
  }
}

class InteractiveWeatherMapScreen extends StatefulWidget {
  @override
  _InteractiveWeatherMapScreenState createState() => _InteractiveWeatherMapScreenState();
}

class _InteractiveWeatherMapScreenState extends State {
  WeatherFactory ws = WeatherFactory(OPENWEATHER_API_KEY);
  List<Map<String, dynamic>> _data = [];
  List<String> cities = [];
  String defaultCity = '';

  @override
  void initState() {
    super.initState();
    fetchUserCities();
  }

  void fetchUserCities() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userSnapshot.exists) {
          String? userCity = userSnapshot['city'];
          List<String?> userCities =
          List<String?>.from(userSnapshot['cities']);
          userCities.removeWhere((city) => city == null);
          if (userCity != null && userCities.isNotEmpty) {
            setState(() {
              cities = userCities.cast<String>();
              defaultCity = userCity;
            });
            queryWeatherForCities();
            }
          } else {
            print('User role not found in document');
          }
      } else {
        print('User ID not found');
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  void queryWeatherForCities() async {
    List<Map<String, dynamic>> newData = [];
    for (String city in cities) {
      CityWeather cityWeather = CityWeather(city: city);
      await cityWeather.fetchCoordinatesAndWeather(ws);
      newData.add({
        'cityWeather': cityWeather,
      });
    }
    setState(() {
      _data = newData;
    });
  }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Interactive Weather Map',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/home_screen');
            },
          ),
      ),
      body: FutureBuilder(
        future: Future.wait(cities.map((city) => CityWeather(city: city).fetchCoordinates())),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 5,
            ),
            mapType: MapType.normal,
            markers: _data.map((cityData) {
            CityWeather cityWeather = cityData['cityWeather'];
              return Marker(
                markerId: MarkerId(cityWeather.city),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
                position: cityWeather.latLng!,
                infoWindow: InfoWindow(
                  title: cityWeather.city,
                  snippet: '${cityWeather.weather?.temperature?.celsius?.toStringAsFixed(1)}°C | ${cityWeather.weather?.weatherMain}',
                ),
              );
            }).toSet(),
              onMapCreated: (GoogleMapController controller) {
                controller.setMapStyle(jsonEncode(customMapStyle));
              },
            );
          }
        },
      ),
    );
  }
}
