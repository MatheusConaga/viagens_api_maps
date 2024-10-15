import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:viagens_google/mapa.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  _abrirMapa( String idViagem ) {

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Mapa( idViagem: idViagem, ),
        ));

  }

  _excluirViagem( String idViagem ) {

    db.collection("viagens").doc(idViagem).delete();

  }

  _adicionarLocal() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Mapa(),
        ));
  }

  _adicionarListenerViagens() async{
    final stream = db.collection("viagens")
        .snapshots();

    stream.listen((dados){

      _controller.add(dados);
      
    });


  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerViagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Minhas viagens",
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _adicionarLocal();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Color(0xff0066cc),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _controller.stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              case ConnectionState.done:

                QuerySnapshot querySnapshot = snapshot.data!;
                List<DocumentSnapshot> viagens = querySnapshot.docs.toList();

                return Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                      itemCount: viagens.length,
                      itemBuilder: (context, index) {

                        DocumentSnapshot item = viagens[index];
                        String titulo = item["titulo"];
                        String idViagem = item.id;

                        return GestureDetector(
                          onTap: () {
                            _abrirMapa( idViagem );
                          },
                          child: Card(
                            child: ListTile(
                              title: Text( titulo ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _excluirViagem( idViagem );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )),
                  ],
                );
                break;
            }
          }),
    );
  }
}
