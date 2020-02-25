import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Communication.dart';
import 'package:flutter_app/Constants.dart';
import 'package:flutter_app/RegisterRout.dart';
import 'package:flutter_app/ConferenceRoute.dart';
import 'package:flutter_app/AboutRout.dart';
import 'package:flutter_app/LoadRout.dart';
import 'Communication.dart';

void main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main title',
      debugShowCheckedModeBanner: false, //remove the debug label from the top
      theme: ThemeData(
        // This is the theme of your application.
        primaryColor: Colors.lightBlue[900], //the color of the phone up bar
        accentColor: Colors.lightBlue[800], //the color of the appbar
        brightness: Brightness.light,
        fontFamily: 'Montserrat',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Color(0x50f0f0f0),
      ),
      home: MyHomePage(title: 'Conference'),
    );
  }
}

///This widget is the home page of your application.
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(widget.title),
        actions: <Widget>[
          //create the three dots menu in the appbar
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context){
              return Constants.choices.map((String choice){
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: SingleChildScrollView( //make a list of all conferenceCards we get
        child: Column(
          children: <Widget>[
            CardsList(),
          ],
        ),
      )
    );
  }

  ///move to relevant page after the user select option in the three dots menu in the appbar
  void choiceAction(String choice){
    if(choice ==Constants.Register){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterRout()),
      );
    }
    else if(choice ==Constants.About){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AboutRout()),
      );
    }
  }
}

///make list of clickable cards from conferenceCards list
class CardsList extends StatefulWidget {
  @override
  _CardsList createState() => _CardsList();
}

class _CardsList extends State<CardsList> {
  List<ConferenceCard> _cards;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadRout()),
    ));
    setState(() {
      _cards = Communication.getConferenceCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder( //build list of items
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _cards.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return makeGestureDetector(_cards[index],
              context); // build list of conferenceCards
        },
      ),
    );
  }
}

///make the card clickable
GestureDetector makeGestureDetector(ConferenceCard card, BuildContext context) => GestureDetector(
  onTap: (){Navigator.push( //on click move to ConferenceRoute with the conferenceCard data
    context,
    MaterialPageRoute(builder: (context) => ConferenceRoute(card: card,)),
  );},
  child: makeCard(card),
);

///make the conferenceCard
Card makeCard(ConferenceCard card) => Card(
  child: Padding(
    padding: EdgeInsets.all(10.0),
    child: Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
    FadeInImage.assetNetwork(//add image to the card
      placeholder: Constants.defaultImage,
      image: card.imageUrl,
        height: Constants.imageW,
        width: Constants.imageW,
    ),
        Container(//make space between the image and the text
          width: 8,
        ),
        Expanded(
          child: Column(//add the text of the card
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(card.date, style: TextStyle(fontSize: 10.0)),//the first line is the date
              Text(card.place, style: TextStyle(fontSize: 10.0),maxLines: 1, overflow:  TextOverflow.ellipsis,),//the second line is the location
              Text(card.title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), maxLines: 1, overflow:  TextOverflow.ellipsis,), //the threes line is conference name
              Text(card.description, maxLines: 2, overflow:  TextOverflow.ellipsis, ), //the fourth line is one or two lines of description
            ],
          ),
        )
      ],
    ),
  ),
);