import 'package:flutter/material.dart';
import 'package:flutter_app/Communication.dart';
import 'package:flutter_app/Communication.dart' as prefix0;
import 'package:flutter_app/Data.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoadRout extends StatelessWidget {
  LoadRout({Key key}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child:Column(
            children: <Widget>[
              Image.asset('images/Conference_big.jpg',),
              Container(//make space
                height: 25,
              ),
              CircularProgressIndicator(),
              Container(//make space
                height: 25,
              ),
              Text("Loading data", style: TextStyle(fontSize: 20.0,),),
              loadDate(context),
            ],
          )
      ),
    );
  }

  Container loadDate(BuildContext context){
    try {
      Storage.loadUser();
      try {
        DataBaseCommunication.loadParticipants();
      }catch(e) {print("ERROR: " + e.toString());}
      DataBaseCommunication.loadData(false).then((result) {
        //Storage.loadData();
        MyData.removeDuplicate();
        Storage.saveData();
        MyData.updateParticipants();
        Navigator.popUntil(
            context, ModalRoute.withName(Navigator.defaultRouteName));
      });
    }catch(e) {
      print("Load ERROR: " + e.toString());
      Fluttertoast.showToast(msg: 'ERROR:' + e.toString());
      Navigator.popUntil(
          context, ModalRoute.withName(Navigator.defaultRouteName));
    }
    return Container();
  }
}