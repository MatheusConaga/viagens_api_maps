import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(-2.957981, -41.770228),
    zoom: 16,
  );
  Set<Marker> _marcadores = {};
  Set<Polyline> _polylines = {};

  _onMapCreated(GoogleMapController googleMapController) {
    _controller.complete(googleMapController);
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(_posicaoCamera),
    );
  }

  _adicionarMarcadorUsuario(Position position) {
    Marker marcadorUsuario = Marker(
      markerId: MarkerId("marcador-usuario"),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(title: "Meu local"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      onTap: () {
        print("meu local clicado");
      },
    );

    setState(() {
      _marcadores.add(marcadorUsuario);
      _posicaoCamera = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 17,
      );
      _movimentarCamera();
    });
  }

  _adicionarListenerLocalizacao() {
    var locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
        print("Localização atual: ${position.toString()}");
        _adicionarMarcadorUsuario(position);
      },
      onError: (error) {
        print("Erro no stream de localização: $error");
      },
    );
  }

  _recuperarLocalEndereco() async {
    try {
      // Obtenha as coordenadas do endereço
      List<Location> locations = await locationFromAddress("Av. Dep. Pinheiro Machado, 713");

      print("Total: ${locations.length}");

      if (locations.isNotEmpty) {
        // Pegue as coordenadas do primeiro local
        Location location = locations[0];
        double latitude = location.latitude;
        double longitude = location.longitude;

        print("Coordenadas: Latitude ${latitude}, Longitude ${longitude}");

        // Obtenha os detalhes do endereço a partir das coordenadas
        List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

        if (placemarks.isNotEmpty) {
          Placemark endereco = placemarks[0];

          String resultado = "";
          resultado = "\n administrativeArea: " + (endereco.administrativeArea ?? "N/A");
          resultado += "\n subAdministrativeArea: " + (endereco.subAdministrativeArea ?? "N/A");
          resultado += "\n locality: " + (endereco.locality ?? "N/A");
          resultado += "\n subLocality: " + (endereco.subLocality ?? "N/A");
          resultado += "\n thoroughfare: " + (endereco.thoroughfare ?? "N/A");
          resultado += "\n subThoroughfare: " + (endereco.subThoroughfare ?? "N/A");
          resultado += "\n postalCode: " + (endereco.postalCode ?? "N/A");
          resultado += "\n country: " + (endereco.country ?? "N/A");
          resultado += "\n isoCountryCode: " + (endereco.isoCountryCode ?? "N/A");

          print("Resultado: $resultado");
        }
      }
    } catch (e) {
      print("Erro: $e");
    }
  }



  @override
  void initState() {
    super.initState();
    // _adicionarListenerLocalizacao();
    _recuperarLocalEndereco();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapas e geolocalização"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _movimentarCamera,
        child: Icon(Icons.done),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _posicaoCamera,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        // markers: _marcadores,
        // polylines: _polylines,
      ),
    );
  }
}
