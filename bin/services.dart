import 'package:mongo_dart/mongo_dart.dart' as mongo;

import 'package:rpc/rpc.dart';
import 'package:flutter_rpc_mongo2/model.dart';
import 'package:flutter_rpc_mongo2/config.dart';
import 'dart:io';

final ApiServer _apiServer = ApiServer(prettyPrint: true);

main(List<String> arguments) async {

  _apiServer.addApi(new NameApi());
  _apiServer.enableDiscoveryApi();

  HttpServer server = await HttpServer.bind(SERVICE_HOST, SERVICE_PORT);
  server.listen(_apiServer.httpRequestHandler);

}





@ApiClass(version: 'v1', name: 'api')
class NameApi {
  List<Name> list = [];

  _loadNames() async {

    //list.clear();
    mongo.Db database = new mongo.Db('mongodb://localhost:27017/obj1');
    mongo.DbCollection collection = database.collection('Person');
    await database.open();
    list.clear();
    var raw = await collection.find().toList();
    print(raw);
    for (var rawName in raw) {
      list.add(new Name.fromMap(rawName));
    }
    await database.close();



  }

  _storeName(Name name) async {
    mongo.Db db = new mongo.Db('mongodb://localhost:27017/obj1');
    mongo.DbCollection collection = db.collection('Person');
    await db.open();
    await collection.save(name.toMap());
    await db.close();
  }

  @ApiMethod(path: "list")
  List<Name> getList() {
    _loadNames();
    return list;
  }

  @ApiMethod(path: "save/{firstName}/x/{lastName}")
  Name saveName(String firstName, String lastName) {

    Name name = new Name(firstName, lastName);
    _storeName(name);
    return name;

  }


}
















