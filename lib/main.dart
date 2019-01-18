import 'package:flutter/material.dart';
import 'package:flutter_rpc_mongo2/model.dart';
import 'package:flutter_rpc_mongo2/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => FirstScreen(),
        '/list': (context) => SecondScreen(),
      },
    ));

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key key}) : super(key: key);

  _FirstScreenState createState() => new _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController firstController = TextEditingController();
  final TextEditingController lastController = TextEditingController();

  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "MongoDB Flutter",
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("MongoDB Flutter"),
        ),
        body: new Column(
          children: <Widget>[
            new TextField(
              controller: firstController,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(labelText: "First Name"),
            ),
            new TextField(
              controller: lastController,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(labelText: "Last Name"),
            ),
          ],
        ),
        floatingActionButton: new FloatingActionButton(
            child: new Icon(Icons.add),
            onPressed: () async {
              String first = firstController.text;
              String last = lastController.text;
              await http.get(
                  "http://${SERVICE_HOST}:${SERVICE_PORT}/api/v1/save/$first/x/$last");
              firstController.text = "";
              lastController.text = "";
              Navigator.pushNamed(context, "/list");
            }),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final String pageName;

  const SecondScreen({Key key, this.pageName}) : super(key: key);

  @override
  _NamesState createState() => _NamesState();
}

class _NamesState extends State<SecondScreen> {
//  List<Name> _names = new List();
  List _names = new List();
  List<Widget> _namesTiles = new List();


  @override
  void initState() {
    super.initState();
    _getNames();
  }

  _getNames() async {
/*    mongo.Db db = new mongo.Db(uriString);
    var collection = db.collection(collectionName);
    await db.open();
    await collection.find().forEach((map) {
      Name name = new Name()
          ..firstName = map['firstName']
          ..lastName = map['lastName'];
      _names.add(name);
    }); */
    http.Response response =
        await http.get("http://${SERVICE_HOST}:${SERVICE_PORT}/api/v1/list");
    String body = response.body;
    print(body);
    var data = jsonDecode(body);
    print("_getNames after decode $data");
    for (var x in data) {
      Name name = new Name(x['firstName'], x['lastName']);
      _names.add(name);
    }

    setState(() {
      for (var x in _names) {
        Text text = new Text("$x");
        _namesTiles.add(text);
      }
    });

    /*  List data = jsonDecode(body);
    for (Map raw in data) {
      Name name = new Name(raw['first_name'], raw['last_name']);
      //       print("Received $name");
      _names.add(name);
    } */

    //   print("received $_names");

/*    setState(() {
      for (Name found in _names) {
        Text text = new Text("$found");
        _namesTiles.add(text);
      }
    });
}
*/
//  _namesTiles.add(new Text(data));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new Scaffold(
        appBar: AppBar(
          title: Text("Name List"),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) => _namesTiles[index],
          itemCount: _namesTiles.length,
        ),
        floatingActionButton: new FloatingActionButton(
            child: new Icon(Icons.fast_rewind),
            onPressed: () => Navigator.pop(context)),
      ),
    );
  }
}
