
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController mapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(22.7196, 75.8577),
    zoom: 14.4746,
  );
  String searchAddr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("InstaCop"),
          backgroundColor: Colors.blueGrey,
        ),
        drawer: Drawer(),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: _kGooglePlex,
            ),
            Positioned(
              top: 30.0,
              right: 15.0,
              left: 15.0,
              child: Container(
                height: 50.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Enter Address',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                      suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: searchandNavigate,
                          iconSize: 30.0)),
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
                alignment: Alignment.bottomCenter,
                child: new RaisedButton(

                  color: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  elevation: 1.0,
                  onPressed: (){},
                  padding: EdgeInsets.fromLTRB(80, 0, 80, 0),
                  child: Text("SOS",
                    style: TextStyle(
                      fontSize: 40.0,
                      color: Colors.white,
                      //decorationThickness: 6.0,
                    ),),
                ),
              ),
            ),
          ],
        ));
  }

  searchandNavigate() {
    Geolocator().placemarkFromAddress(searchAddr).then((result) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
          LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 10.0)));
    });
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }
}
