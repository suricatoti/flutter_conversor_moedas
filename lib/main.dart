import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=20fad397";

void main() async {
  runApp(MaterialApp(
    home: Home(),
  theme: ThemeData(
    hintColor: Colors.amber,
    primaryColor: Colors.white
  ),));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String value) {
    if(value.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(value);
    dolarController.text = (real/dolar).toStringAsPrecision(2);
    euroController.text = (real/euro).toStringAsPrecision(2);
  }

  void _dolarChanged(String value) {
    if(value.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.tryParse(value);
    realController.text = (dolar * this.dolar).toStringAsPrecision(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsPrecision(2);
  }

  void _euroChanged(String value) {
    if(value.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.tryParse(value);
    realController.text = (euro * this.euro).toStringAsPrecision(2);
    euroController.text = (euro * this.euro / dolar).toStringAsPrecision(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Conversor de Moedas \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text("Carregando dados!",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Erro ao carregar dados :(",
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                          textAlign: TextAlign.center));
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on, size:  150.0, color: Colors.amber),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField("Euros", "€", euroController, _euroChanged)
                      ],
                    ),
                  );
                }
            }
          },
        )
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function f) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        prefixText: prefix
    ),
    controller: controller,
    onChanged: f,
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25.0
    ),
    keyboardType: TextInputType.numberWithOptions(decimal: true)
  );
}