import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Constants.dart';
import 'package:flutter_app/LectureRoute.dart';
import 'package:flutter_app/Communication.dart';
import 'package:flutter_app/Data.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'RegisterRout.dart';

ConferenceCard conferenceCard;

class ConferenceRoute extends StatelessWidget {
  final ConferenceCard card;

  ConferenceRoute({Key key, @required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    card.sortLectures();
    conferenceCard = card;
    return Scaffold(
      appBar: AppBar(
        title: Text(card.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //the conference data:
            Center(
              child: FadeInImage.assetNetwork(
                //add image to the card
                placeholder: Constants.defaultImage,
                image: card.imageUrl,
              ),
            ),
            Text(card.date, style: TextStyle(fontSize: 18.0)),
            Text(
              card.place,
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              card.title,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Text(
              card.description,
            ),
            Divider(
              color: Colors.indigo,
            ),
            BuildStatefulButton(),
            //the conference lectures:
            CardsList(),
          ],
        ),
      ),
    );
  }
}

///the planer button
class BuildStatefulButton extends StatefulWidget {
  @override
  _BuildStatefulButton createState() => _BuildStatefulButton();
}

class _BuildStatefulButton extends State<BuildStatefulButton> {
  _BuildStatefulButton({this.conferenceName});
  @required final String conferenceName;
  Color buttonColor;
  String buttonText;

  @override
  void initState() {
    super.initState();
    setState(() {
      if(!conferenceCard.userAddToPlaner){
        buttonColor = Colors.blueAccent;
        buttonText = "Register to Conference";
      }else{
        buttonColor = Colors.orange;
        buttonText = "Cancel registration";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      child: RaisedButton(
        color: buttonColor,
        child: Text(buttonText),
        onPressed: () {
          //if the user not registered forward to register
          if(currentUser == null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterRout()),
            );
          }
          //if register canceled
          if(currentUser != null){
            toggleButton();
          }
        },
      ),
    );
  }

  ///switch the text and color of planner button
  void toggleButton(){
    setState(() {
      if(buttonColor == Colors.blueAccent){
        buttonColor = Colors.orange;
        buttonText = "Cancel registration";
        conferenceCard.toggleUserAddToPlaner();
        addToCalendar();
        DataBaseCommunication.insertParticipants(currentUser, conferenceCard.title);
        Fluttertoast.showToast(msg: 'User registered to conference');
        Storage.saveData();
      }
      else{
        buttonColor = Colors.blueAccent;
        buttonText = "Register to Conference";
        //todo: Cancel registration
      }
      MyData.toggleAddToPlanerStatus(conferenceCard);
    });
  }


  ///add to calender
  void addToCalendar(){
    DateTime startTime = MyData.dataTimeFromString(conferenceCard.date, conferenceCard.getMinLectureStartTime());
    DateTime endTime = MyData.dataTimeFromString(conferenceCard.date, conferenceCard.getMaxLectureEndTime());
    //create the event
    final Event event = Event(
      title: conferenceCard.title,
      location: conferenceCard.place,
      startDate: startTime,
      endDate: endTime,
    );
    //set the event
    Add2Calendar.addEvent2Cal(event);
  }
}

///build list of cards of lectures
class CardsList extends StatefulWidget {
  final ConferenceCard card = conferenceCard;

  @override
  _CardsList createState() => _CardsList(card);
}

class _CardsList extends State<CardsList> {
  ConferenceCard card;
  List<Lecture> cards;
  _CardsList(this.card);

  @override
  void initState() {
    super.initState();
    setState(() {
      cards = conferenceCard.lectures;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: cards.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return makeGestureDetector(cards[index],context, update);
        },
      ),
    );
  }

  ///function to update the cards from switch to parallel lecture button.
  void update(){
    setState(() {
      cards = conferenceCard.lectures;
    });
  }
}

///make clickable card
GestureDetector makeGestureDetector(Lecture card, BuildContext context, var update) =>
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LectureRout(lecture: card,)),
        );
      },
      child: makeCard(card, update),
    );

///card with the lecture details.
Card makeCard(Lecture card, var update) => Card(
  child: Padding(
    padding: EdgeInsets.all(10.0),
    child: Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(children: <Widget>[
          ///print time
          Text(card.startTime, style: TextStyle(fontSize: 15.0)),
          Text(card.endTime, style: TextStyle(fontSize: 15.0)),
        ]),
        Container(
          //Divider
          width: 8,
        ),
        Expanded(
          child: Column(
            ///add the text of the card
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ///the lecture name
              Text(
                card.lectureName,
                maxLines: 1,
                style:
                TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),

              ///the location
              Row(
                children: <Widget>[
                  Icon(Icons.location_on),
                  Flexible(
                    child: Text(
                      card.place,
                      style: TextStyle(fontSize: 18.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
              ///the lecturers
              buildLecturers(card),
            ],
          ),
        ),
        ///the button to switch to parallel lecture if have, or empty place if don't
        BuildTabButton(lecture: card, update: update,)
      ],
    ),
  ),
);

///build string of all lecturers or return empty container
Widget buildLecturers(Lecture lecture) {
  String lecturers = "";
  if (lecture != null &&
      lecture.lecturers != null &&
      lecture.lecturers.isNotEmpty) {
    for (int i = 0; i < lecture.lecturers.length; i++) {
      if (i != 0) lecturers += ", ";
      lecturers += lecture.lecturers[i].name;
    }
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
              fit: FlexFit.loose,
              child: Text(
                lecturers,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18.0),
                softWrap: false,
              )
          ),
        ],
      ),
    );
  } else
    return Container();
}

///build button for switch between parallel lecture if have
class BuildTabButton extends StatelessWidget {
  BuildTabButton({this.lecture, this.update});

  @required
  final Lecture lecture;
  final update;

  @override
  Widget build(BuildContext context) {
    if (!haveParallel(lecture)) return Container();
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      child: RaisedButton(
        child: Icon(Icons.compare_arrows),
        onPressed: () {
          changeToParallel();
          conferenceCard.sortLectures();
          update();
        },
      ),
    );
  }

  ///return true if have another lecture in same time
  bool haveParallel(Lecture lecture) {
    for (Lecture pLecture in conferenceCard.parallelLectures) {
      if (pLecture.startTime == lecture.startTime && pLecture.lectureName != lecture.lectureName) return true;
    }
    return false;
  }

  ///switch between the lecture and the parallel lecture
  void changeToParallel(){
    for (Lecture pLecture in conferenceCard.parallelLectures) {
      if (pLecture.startTime == lecture.startTime){
        conferenceCard.parallelLectures.add(lecture);
        conferenceCard.lectures.add(pLecture);
        conferenceCard.parallelLectures.remove(pLecture);
        conferenceCard.lectures.remove(lecture);
        return;
      }
    }
  }
}