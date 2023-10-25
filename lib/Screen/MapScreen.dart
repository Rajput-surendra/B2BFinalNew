import 'dart:async';
import 'package:b2b/Model/temp_model.dart';
import 'package:b2b/widgets/Appbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class Gogglemap extends StatefulWidget {
   Gogglemap({super.key,this.tempMode2});
 List <TempMode2>? tempMode2;

  @override
  State<Gogglemap> createState() => _GogglemapState();
}
class _GogglemapState extends State<Gogglemap> {
  late GoogleMapController mapController;

  // final Set<Marker> markers = {
  //   Marker(
  //     markerId: MarkerId('1'),
  //     position: LatLng(22.751247256865494, 75.89504445001252), // Replace with the coordinates of your placeMark
  //     infoWindow: InfoWindow(title: 'Vijay Nagar'),
  //   ),
  //   // Add more markers as needed
  // };
List  <Marker> list = [];

 List <String> lat = [];
 List <String> long = [];
 List <String> restoName = [];
  // Completer<GoogleMapController> _controller =Completer();
  // static final CameraPosition _kGoogle= const CameraPosition(
  //   target: LatLng(22.73140, 75.90821),
  //   zoom: 14.4746,
  // );
  // final List<Marker> _marker =[];
  // final List<Marker> _list = const [
  //   Marker(
  //       markerId: MarkerId('1'),
  //       position:  LatLng(22.73140, 75.90821),
  //       infoWindow: InfoWindow(
  //           title: 'Khajrana Ganesh mandir'
  //       )
  //   ),
  //   //
  //   // Marker(
  //   //     markerId: MarkerId('2'),
  //   //     position:  LatLng(22.74524188218821, 75.89394531293044),
  //   //     infoWindow: InfoWindow(
  //   //         title: 'C21'
  //   //     )
  //   // ),
  //   // Marker(
  //   //     markerId: MarkerId('3'),
  //   //     position:  LatLng(22.751247256865494, 75.89504445001252),
  //   //     infoWindow: InfoWindow(
  //   //         title: 'Vijay nagar'
  //   //     )
  //   // ),
  //   // Marker(
  //   //     markerId: MarkerId('4'),
  //   //     position:  LatLng(22.747763486587218, 75.93392486766031),
  //   //     infoWindow: InfoWindow(
  //   //         title: 'Phonix'
  //   //     )
  //   // ),
  //   // Marker(
  //   //     markerId: MarkerId('5'),
  //   //     position:  LatLng(22.745063540584127, 75.87830314501237),
  //   //     infoWindow: InfoWindow(
  //   //         title: 'Nanda nagar'
  //   //     )
  //   // ),
  //   // Marker(
  //   //     markerId: MarkerId('6'),
  //   //     position:  LatLng(22.749437698014606, 75.90354121091355),
  //   //     infoWindow: InfoWindow(
  //   //         title: 'Radisson Square'
  //   //     )
  //   // ),
  //   // Marker(
  //   //     markerId: MarkerId('7'),
  //   //     position:  LatLng(22.75457023607151, 75.90358801091365),
  //   //     infoWindow: InfoWindow(
  //   //         title: 'Bombay Hospital'
  //   //     )
  //   // ),
  //   // Marker(
  //   //     markerId: MarkerId('8'),
  //   //     position:  LatLng(22.72528564135569, 75.88389942408358),
  //   //     infoWindow: InfoWindow(
  //   //         title: 'New palasia '
  //   //     )
  //   // ),
  // ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAddressFromLatLng();
    widget.tempMode2?.forEach((element) {
      element.temp?.forEach((element) {
        if(element.lat != '' && element.lang != '' )
        {
          lat.add(element.lat ?? "0.0");
          long.add(element.lang ?? "0.0");
        }
        restoName.add(element.storeName ?? "");
        print('____xxZx______${element.lat}____${element.lang}_____');
      });
    });

    for(int i =0; i<lat.length;i ++ ){
      list.add(Marker(
        markerId: MarkerId('1'),
        position: LatLng(double.parse(lat[i]), double.parse(long[i])), // Replace with the coordinates of your placeMark
        infoWindow: InfoWindow(title: restoName[i]),
      ),);

    }
  }
  var homelat;
  var homeLong;
  String? _currentAddress;
  Position? currentLocation;
  _getAddressFromLatLng() async {
    await getUserCurrentLocation().then((_) async {
      try {
        print("Addressss function");
        List<Placemark> p = await placemarkFromCoordinates(
            currentLocation!.latitude, currentLocation!.longitude);
        Placemark place = p[0];
        setState(() {
          _currentAddress =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";

        });
      } catch (e) {
        print('errorrrrrrr ${e}');
      }
    });
  }
  Future getUserCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
      Fluttertoast.showToast(msg: "Permision is requiresd");
    } else if (status.isGranted) {
      await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high)
          .then((position) {
        if (mounted) {
          setState(() {
            currentLocation = position;
            homelat = currentLocation?.latitude;
            homeLong = currentLocation?.longitude;
          });
        }
      });
      print("LOCATION===" + currentLocation.toString());
      print('_____LOCATION===>>>>>>>_____${homelat}___${homeLong}______');
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, text: "Near Sellers", isTrue: false),
      body:  homelat  == null ? Center(child: CircularProgressIndicator()):GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(homelat, homeLong), // Initial map coordinates
          zoom: 14.0, // Initial zoom level
        ),
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        markers:Set<Marker>.of(list),
      ),
    );

      // GoogleMap(
      //   onMapCreated: (GoogleMapController controller){_controller.complete(controller);},
      //   initialCameraPosition: _kGoogle,
      //   markers:Set<Marker>.of(_list),
      //   myLocationEnabled: true,
      //
      // ),


  }
}