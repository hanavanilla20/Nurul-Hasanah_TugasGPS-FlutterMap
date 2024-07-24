import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geo Tagging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GPS FLUTTER MAP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String strLatLong = 'Belum mendapatkan Lat dan Long. Silahkan tekan tombol';
  String strLokasi = 'Search Location...';
  bool loading = false;

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      strLokasi =
      '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Titik Koordinat',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              child: Text(strLatLong),
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: strLatLong));
                final snackBar = SnackBar(
                  content: const Text('Latlong berhasil disalin.'),
                  backgroundColor: Colors.blue,
                  action: SnackBarAction(
                    textColor: Colors.white,
                    label: 'Close',
                    onPressed: () {},
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Lokasi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: GestureDetector(
                child: Text(strLokasi),
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: strLokasi));
                  final snackBar = SnackBar(
                    content: const Text('Lokasi berhasil disalin.'),
                    backgroundColor: Colors.blue,
                    action: SnackBarAction(
                      textColor: Colors.white,
                      label: 'Close',
                      onPressed: () {},
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(Colors.lightBlue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  loading = true;
                });

                Position position = await _getGeoLocationPosition();
                setState(() {
                  loading = false;
                  strLatLong =
                  '${position.latitude}, ${position.longitude}';
                });

                getAddressFromLongLat(position);
              },
              child: const Text('Tagging Lokasi'),
            ),
          ],
        ),
      ),
    );
  }
}
