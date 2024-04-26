import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CityWeather {
  final String cityName;
  final double temperature;
  final String weatherIcon;
  LatLng? latLng;

  CityWeather({
    required this.cityName,
    required this.temperature,
    required this.weatherIcon,
  });

  Future<void> fetchCoordinates() async {
    final apiKey = 'AIzaSyAQeHSeTN6iqdezyleUpLJN0fQvuUIQlL4'; // Replace with your Google Maps API key
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$cityName&key=$apiKey';
    
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

class InteractiveWeatherMapScreen extends StatelessWidget {
  final List citiesWeather = [
  CityWeather(
  cityName: 'San Francisco',
  temperature: 70.0,
  weatherIcon: '☀️',
  ),
  CityWeather(
  cityName: 'New York',
  temperature: 65.0,
  weatherIcon: '⛅',
  ),
  CityWeather(
  cityName: 'Los Angeles',
  temperature: 75.0,
  weatherIcon: '🌤️',
  ),
  CityWeather(
  cityName: 'Atlanta',
  temperature: 75.0,
  weatherIcon: '🌤️',
  ),
  // Add more cities as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Interactive Weather Map'),
      ),
      body: FutureBuilder(
        future: Future.wait(citiesWeather.map((city) => city.fetchCoordinates())),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
          } else {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Initial position set to San Francisco
              zoom: 5,
            ),
            mapType: MapType.normal,
            markers: citiesWeather.map((city) {
            return Marker(
              markerId: MarkerId(city.cityName),
              position: city.latLng!,
              infoWindow: InfoWindow(
                title: city.cityName,
                snippet: '${city.temperature}°C ${city.weatherIcon}',
              ),
            );
            }).toSet(),
            onMapCreated: (GoogleMapController controller) {},
            );
          }
        },
      ),
    );
  }
}

