
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
          backgroundColor: Colors.blueGrey,
        ),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                ),
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('History'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Tell a friend'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: Icon(Icons.security),
                title: Text('Anonymous Tip'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help and Support'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),ListTile(
                leading: Icon(Icons.info),
                title: Text('About'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: Icon(Icons.lock_open),
                title: Text('Logout'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              markers: _markers,
              onCameraMove: _onCameraMove,
              onMapCreated: onMapCreated,
              initialCameraPosition:  indore,
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
                        /*suffixIcon: IconButton(
                            icon: Icon(Icons.my_location),
                            onPressed: get_current_location,
                            iconSize: 30.0)*/),
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
                  backgroundColor : Colors.red,
                  onPressed: sos_pressed,
                  child: Text("SOS"),
                ),
              ),
            ),
            Positioned(
              bottom: 100.0,
              right : 13.0,
              child: FloatingActionButton(
                onPressed: get_current_location,
                child : Icon(Icons.my_location),
              ),
            ),
            Positioned(
              bottom: 180.0,
              right : 13.0,
              child: FloatingActionButton(
                onPressed: _onAddMarkerButtonPressed,
                child : Icon(Icons.add_location),
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

  get_current_location() async{
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    debugPrint("Current Location" + currentLocation.toString());
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom : 20.0,
    )));
  }

  _onCameraMove(CameraPosition position){
    lastCameraPosition = position.target;
    debugPrint(lastCameraPosition.toString());
  }


  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  void sos_pressed(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Please Confirm"),
          content: new Text("Do you want to send an SOS signal"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _onAddMarkerButtonPressed() {
    marked = !marked;
    setState(() {
      if(!marked){
        _markers.add(Marker(
          // This marker id can be anything that uniquely identifies each marker.
          markerId: MarkerId(lastCameraPosition.toString()),
          position: lastCameraPosition,
          infoWindow: InfoWindow(
            title: 'User Name',
            snippet: 'Crime Report Here',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(20.0),
        ));
      }
      if(marked){
        _markers.clear();
      }
    });
  }
}



