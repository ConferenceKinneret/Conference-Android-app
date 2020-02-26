import 'package:flutter/material.dart';
import 'package:flutter_app/Constants.dart';
import 'package:flutter_app/LecturerRoute.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';


class LectureRout extends StatelessWidget{
  final Lecture lecture;

  LectureRout({Key key, @required this.lecture}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lecture.lectureName),
      ),

      body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Show the lecture title
            Text(lecture.lectureName,
              style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold),),
            Divider(
              color: Colors.lightBlue,
            ),
            buildTime(),
            buildPlace(),

            buildLecturers(lecture.lecturers),
            Divider(
              color: Colors.lightBlue,
            ),
            buildFileButton(),

            Text(lecture.description, style: TextStyle(fontSize: 20.0,),),
          ]
      ),
      ),
    );
  }

  ///Add the start and end time with clock icon
  Widget buildTime() {
    return Container(
      child: Row(
        children: <Widget>[
          Icon(Icons.access_time),
          Text(lecture.startTime + " - " + lecture.endTime, style: TextStyle(fontSize: 20.0,),),
        ],
      ),
    );
  }

  ///Add place with place icon
  Widget buildPlace() {
    return Container(
      child: Row(
        children: <Widget>[
          Icon(Icons.place),
          Text(lecture.place, style: TextStyle(fontSize: 20.0,),),
        ],
      ),
    );
  }


  ///The button to download the lecture file if have one
  Widget buildFileButton() {
    if (lecture.file != null && lecture.file != "") {
      return Container(
        child: Center(
          child: RaisedButton(
            child: Text("Dowmload lecture file"),
            onPressed: _launchURL,
          ),
        ),
      );
    }else return Container();
  }
  ///Part of download button
  _launchURL() async {
    final url = lecture.file;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: 'Failed to open url');
    }
  }

}


Widget buildLecturers(List<Lecturer> lecturers) {
  if(lecturers != null && lecturers.isNotEmpty) return Container(
    child: ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: lecturers.length,
      itemBuilder: (BuildContext context, int index) {
        return BuildLecturer(lecturer: lecturers[index],);
      },
    ),
  );
  else return Container();
}

class BuildLecturer extends StatelessWidget {
  BuildLecturer({this.lecturer});

  @required final Lecturer lecturer;

  @override
  Widget build(BuildContext context) {
    if (lecturer != null)
      return Container(
        child: InkWell(
            child: Row(
              children: <Widget>[
                icon(lecturer),
                text(lecturer),
              ],),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LecturerRout(lecturer: lecturer,)),
              );
            }),
      );
    else
      return Container();
  }

  Widget icon(Lecturer lecturer) {
    if (lecturer.main)
      return Icon(Icons.person);
    else
      return Icon(Icons.person_outline);
  }

  Widget text(Lecturer lecturer) {
    if (lecturer.main)
      return Text(lecturer.name,
        style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),);
    else
      return Text(lecturer.name, style: TextStyle(fontSize: 20.0),);
  }
}

/*
//to future implement
class BuildButton extends StatelessWidget {
  BuildButton({this.lectureId});
  @required final int lectureId;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      child: RaisedButton(
        child: Text("Add to planner"),
        onPressed: () {
          Communication.registerToLecture(lectureId);
        },
      ),
    );
  }
}*/