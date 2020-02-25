import 'package:flutter/material.dart';
import 'package:flutter_app/Constants.dart';

class AboutRout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About this app"),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Text("About this app",
                style: TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
              ),
              Divider(
                color: Colors.indigo,
              ),
              Text("Version: 1.1"),
              Text(Constants.aboutText),
            ]),
          ),
        ],
      ),
    );
  }
}

