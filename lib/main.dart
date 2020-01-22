import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import './login_page.dart';
import './signup_page.dart';
import './app_drawer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "InstaCop",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/signup',
      routes: {
        '/login': (_) => LoginPage(),
        '/signup': (_) => SignupPage(),
        '/map': (_) => MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController mapController;
  bool marked = true;
  final Set<Marker> _markers = {};

  static final CameraPosition indore = CameraPosition(
    target: LatLng(22.7196, 75.8577),
    zoom: 14.4746,
  );

  LatLng lastCameraPosition = indore.target;
  String searchAddr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("InstaCop"),
      ),
      drawer: AppDrawer(),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            markers: _markers,
            onCameraMove: _onCameraMove,
            onMapCreated: onMapCreated,
            initialCameraPosition: indore,
          ),
          Positioned(
            top: 30.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter Address',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                ),
                onChanged: (val) {
                  setState(() {
                    searchAddr = val;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: new FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () {},
                child: Text("SOS"),
              ),
            ),
          ),
          Positioned(
            bottom: 100.0,
            right: 13.0,
            child: FloatingActionButton(
              onPressed: getCurrentLocation,
              child: Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 180.0,
            right: 13.0,
            child: FloatingActionButton(
              onPressed: _onAddMarkerButtonPressed,
              child: Icon(Icons.add_location),
            ),
          ),
        ],
      ),
    );
  }

  searchandNavigate() {
    Geolocator().placemarkFromAddress(searchAddr).then((result) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              result[0].position.latitude,
              result[0].position.longitude,
            ),
            zoom: 10.0,
          ),
        ),
      );
    });
  }

  getCurrentLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    debugPrint("Current Location" + currentLocation.toString());
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 20.0,
        ),
      ),
    );
  }

  _onCameraMove(CameraPosition position) {
    lastCameraPosition = position.target;
    debugPrint(lastCameraPosition.toString());
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onAddMarkerButtonPressed() {
    marked = !marked;
    setState(() {
      if (!marked) {
        _markers.add(
          Marker(
            // This marker id can be anything that uniquely identifies each marker.
            markerId: MarkerId(lastCameraPosition.toString()),
            position: lastCameraPosition,
            infoWindow: InfoWindow(
              title: 'User Name',
              snippet: 'Crime Report Here',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(20.0),
          ),
        );
      }
      if (marked) {
        _markers.clear();
      }
    });
  }
}
