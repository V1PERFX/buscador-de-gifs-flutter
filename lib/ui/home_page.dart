import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:buscadordegif/ui/gif_page.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _procurar;

  int _offset = 0;

  Future<Map> _pegarGifs() async {
    http.Response respostah;
    if(_procurar == null || _procurar.isEmpty)
      respostah = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=API-KEY-AQUI&limit=20&rating=G");
    else
      respostah = await http.get("https://api.giphy.com/v1/gifs/search?api_key=API-KEY-AQUIhv&q=$_procurar&limit=19&offset=$_offset&rating=G&lang=pt");

    return json.decode(respostah.body);
  }

  @override
  void initState(){
    super.initState();
    _pegarGifs().then((map){
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[900],
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
            decoration: InputDecoration(
              labelText: "Pesquise aqui",
              labelStyle: TextStyle(color: Colors.white),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amberAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amberAccent),
              ),
            ),
            style: TextStyle(color: Colors.white, fontSize: 20,),
            textAlign: TextAlign.center,
            onSubmitted: (texto){
              setState(() {
                _procurar = texto;
                _offset = 0;
              });
            },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _pegarGifs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                    default:
                      if(snapshot.hasError) return Container();
                      else return _criarTabelaGif(context, snapshot);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _pegarContagem(List data){
    if(_procurar == null){
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _criarTabelaGif(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _pegarContagem(snapshot.data["data"]),
      itemBuilder: (context, index){
        if(_procurar == null || index < snapshot.data["data"].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
          onTap: (){
            Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => GifPage(snapshot.data["data"][index]))
            );
          },
          onLongPress: (){
            Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
          },
        );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70,),
                  Text("Carregar mais...",
                  style: TextStyle(color: Colors.white, fontSize: 22),),
                ],
              ),
              onTap: (){
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
      }
    );
  }
}