import 'package:flutter/material.dart';
import 'package:project_2/consts.dart';
import 'package:project_2/sign_in_screen.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _defaultCityController = TextEditingController();

  String? city = '';
  bool enableTemperatureNotification = false;
  bool enableConditionNotification = false;
  WeatherFactory ws = new WeatherFactory(OPENWEATHER_API_KEY);

  @override
  void initState() {
    super.initState();
    fetchUserSettings();
  }

  Future<void> fetchUserSettings() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userSnapshot.exists) {
          setState(() {
            _firstNameController.text = userSnapshot['firstName'] ?? '';
            _lastNameController.text = userSnapshot['lastName'] ?? '';
            _defaultCityController.text = userSnapshot['city'] ?? '';
            enableTemperatureNotification = userSnapshot['enableTemperatureNotification'] ?? false;
            enableConditionNotification = userSnapshot['enableConditionNotification'] ?? false;
          });
        } else {
          print('User document not found');
        }
      } else {
        print('User ID not found');
      }
    } catch (e) {
      print('Error fetching user settings: $e');
    }
  }

  Future<void> saveUserSettings() async {
    try {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'city': _defaultCityController.text,
          'enableTemperatureNotification': enableTemperatureNotification,
          'enableConditionNotification': enableConditionNotification,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text('Settings updated successfully'),
            ),
          );
          } else {
            print('User ID not found');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text('Failed to update settings: $e'),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  void addCity() async {
    String? newCity = _defaultCityController.text.trim();
    if (newCity.isNotEmpty) {
      Weather? weather = await ws.currentWeatherByCityName(newCity);
      if (weather != null) {
        setState(() {
          city = newCity;
          _defaultCityController.clear();
        });
        await saveUserSettings();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.blue)),
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                cursorColor: Colors.blue,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                cursorColor: Colors.blue,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _defaultCityController,
                decoration: InputDecoration(
                  labelText: 'Default City',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                cursorColor: Colors.blue,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    Text('Temperature Notification', style: TextStyle(color: Colors.white)),
                    Switch(
                      value: enableTemperatureNotification,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          enableTemperatureNotification = value;
                        });
                      },
                    ),
                  ],),
                  Column( children: [
                    Text('Condition Notification', style: TextStyle(color: Colors.white)),
                    Switch(
                      value: enableConditionNotification,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          enableConditionNotification = value;
                        });
                      },
                    ),
                  ],)
                ],
              ),
              SizedBox(height:250),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                  FirebaseAuth.instance.signOut();
                },
                child: Text(
                  'Log Out',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  saveUserSettings();
                },
                child: Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
