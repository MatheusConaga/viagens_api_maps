import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:viagens_google/home.dart';
import 'package:viagens_google/inicio.dart';
import 'package:viagens_google/splash/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Necessário para operações assíncronas no main()
  await Firebase.initializeApp();
  // Verifica e solicita permissões de localização
  await _handleLocationPermission();

  runApp(MaterialApp(
    title: "Minhas viagens",
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

// Função para verificar e solicitar permissões de localização
Future<void> _handleLocationPermission() async {
  LocationPermission permission;

  // Verifica se os serviços de localização estão habilitados
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Se os serviços não estão habilitados, você pode exibir uma mensagem ou tratar isso aqui
    print("Serviço de localização desabilitado.");
  }

  // Verifica o status da permissão atual
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // Solicita a permissão se ela estiver negada
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Se o usuário negar a permissão, exiba uma mensagem ou trate o erro
      print("Permissão de localização negada.");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Se o usuário negou permanentemente a permissão, você pode direcioná-lo para as configurações
    print("Permissão de localização permanentemente negada.");
  }

  // Se a permissão foi concedida, continue com a lógica do aplicativo
  if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
    print("Permissão de localização concedida.");
  }
}
