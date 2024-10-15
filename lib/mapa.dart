import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class Mapa extends StatefulWidget {
  final String? idViagem; // Permitir que idViagem seja nulo

  const Mapa({super.key, this.idViagem});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Set<Marker> _marcadores = {};
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(-2.958793, -41.770277),
    zoom: 18,
  );
  FirebaseFirestore db = FirebaseFirestore.instance;

  Completer<GoogleMapController> _controller = Completer();

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _adicionarMarcador(LatLng latLng) async {
    List<Placemark> listaEnderecos = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );

    if (listaEnderecos.isNotEmpty) {
      Placemark endereco = listaEnderecos[0];
      String rua = endereco.thoroughfare ?? "N/A";

      Marker marcador = Marker(
        markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
        position: latLng,
        infoWindow: InfoWindow(title: rua),
      );

      setState(() {
        _marcadores.add(marcador);

        // Salvar no Firebase
        Map<String, dynamic> viagem = {
          "titulo": rua,
          "latitude": latLng.latitude,
          "longitude": latLng.longitude,
        };

        db.collection("viagens").add(viagem);
      });
    }
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(_posicaoCamera),
    );
  }

  _adicionarListenerLocalizacao() {
    var locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      setState(() {
        _posicaoCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 18,
        );
        _movimentarCamera();
      });
    });
  }

  _recuperaViagemID(String? idViagem) async { // Aceitar parâmetro nulo
    if (idViagem != null) { // Verificar se idViagem não é nulo
      DocumentSnapshot documentSnapshot = await db
          .collection("viagens")
          .doc(idViagem)
          .get();

      var dados = documentSnapshot.data();

      if (dados != null && dados is Map<String, dynamic>) {
        String titulo = dados["titulo"] ?? "Título padrão";
        LatLng latLng = LatLng(dados["latitude"] ?? 0.0, dados["longitude"] ?? 0.0);

        setState(() {
          Marker marcador = Marker(
            markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
            position: latLng,
            infoWindow: InfoWindow(title: titulo),
          );
          _marcadores.add(marcador);
          _posicaoCamera = CameraPosition(target: latLng, zoom: 18);
          _movimentarCamera();
        });
      }
    } else {
      _adicionarListenerLocalizacao(); // Chamar quando idViagem for nulo
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperaViagemID(widget.idViagem); // Passar o idViagem
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Mapa",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _posicaoCamera,
        markers: _marcadores,
        onMapCreated: _onMapCreated,
        onLongPress: _adicionarMarcador,
        myLocationEnabled: true,
      ),
    );
  }
}
