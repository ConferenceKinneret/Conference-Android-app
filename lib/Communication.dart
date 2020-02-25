import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter_app/Constants.dart';
import 'package:flutter_app/Data.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path_provider/path_provider.dart';


class Communication{
  static List<ConferenceCard> getConferenceCards(){
    return MyData.getConferenceCards;
  }

  static List<Lecture> getLectureCards(){
    return MyData.getLectureCards;
  }

  static void registerToLecture(int lectureID){//todo: remove it
    User user = currentUser;
  }
}

class DataBaseCommunication{
  static Future<MySqlConnection> get connection async {
    String host = MyData.getHost();
    String dataBase = MyData.getDataBase();
    String userName = MyData.getUserName();
    String pass = MyData.getPassword();
    int port = 3306;
    try {
      final connection = await MySqlConnection.connect(new ConnectionSettings(
        host: host,
        port: port,
        user: userName,
        password: pass,
        db: dataBase,
      ));
      return connection;
    }catch(e){print("ERROR: " + e.toString());}//todo remove
  }

  static Future<Results>  runQuery(String myQuery) async {
    var myConnection;
    try {
      myConnection = await connection;
    }catch(e){print("ERROR: " + e.toString());}

    //run the query
    var results = await myConnection.query(myQuery);

    //close the connection
    await myConnection.close();

    return results;
  }


  static Future<List<ConferenceCard>> loadData(bool loadAll) async {
    final res0 = await loadParticipants();
    final res1 = await loadLecturers();
    final res2 = await loadLecture();
    final res3 = await loadConference(loadAll);
    //remove duplicate
    MyData.removeDuplicate();
    //update cards
    MyData.updateCards();
    return Communication.getConferenceCards();
  }

  ///Load participants
  static Future<bool> loadParticipants() async{
    String publish;
    if(currentUser == null || currentUser.email == null) return false;
    else publish = " where " + DataBaseConstant.participantsEmailColumnString + " LIKE '" + currentUser.email.split("@")[0] + "%'";
    String myQuery = "select * from "  + DataBaseConstant.participantsTableName + publish;
    Results results = await DataBaseCommunication.runQuery(myQuery);
    for(var row in results){
      MyData.addParticipants(row[DataBaseConstant.participantsConferenceNameColumnString]);
    }
    return true;
  }


  ///Load Conference from the server database
  static Future<bool> loadConference(bool loadAll) async{//get all conferences
    String publish = loadAll ? "" : " where publish = 1";
    String myQuery = "select * from "  + DataBaseConstant.conferenceTableName + publish;
    Results results = await DataBaseCommunication.runQuery(myQuery);
    ConferenceCard conferenceCard;
    for(var row in results) {
      conferenceCard = new ConferenceCard(row[DataBaseConstant.conferenceNameColumn],
        row[DataBaseConstant.conferenceDescriptionColumn],
        row[DataBaseConstant.conferenceImageColumn],
        row[DataBaseConstant.conferenceLocationColumn],
        row[DataBaseConstant.conferenceDateColumn],
        false
      );
      for(String participantsInConference in MyData.getMyParticipants){
        if(participantsInConference == conferenceCard.title) conferenceCard.userAddToPlaner = true;
      }
      MyData.addConference(conferenceCard);
    }
    //MyData.updateConference();
    return true;
  }

  ///Load Lecture from the server database
  static Future<bool> loadLecture() async {//get all lectures
    String myQuery = "select * from " + DataBaseConstant.lectureTableName;
    Results results = await DataBaseCommunication.runQuery(myQuery);
    Lecture lecture;
    for(var row in results) {
      lecture = new Lecture(
        conferenceName: row[DataBaseConstant.lectureConferenceNameColumn],
        lectureName: row[DataBaseConstant.lectureNameColumn],
        startTime: row[DataBaseConstant.lectureStartColumn],
        endTime: row[DataBaseConstant.lectureEndColumn],
        place: row[DataBaseConstant.lectureLocationColumn],
        description: row[DataBaseConstant.lectureDescriptionColumn],
        file: row[DataBaseConstant.lectureFileColumn],
        lecturers: [],
      );
      MyData.addLecture(lecture);
    }
    //MyData.updateLectures();
    return true;
  }

  ///Load Lecturers from the server database
  static Future<bool> loadLecturers() async {//get all lecturers
    String myQuery = "select * from " + DataBaseConstant.lecturerTableName;
    Results results = await DataBaseCommunication.runQuery(myQuery);
    Lecturer lecturer;
    for(var row in results){
      //get Lecture
      lecturer = new Lecturer(
          name: row[DataBaseConstant.lecturerNameColumn],
          company: row[DataBaseConstant.lecturerCompanyColumn],
          role: row[DataBaseConstant.lecturerRoleColumn],
          cv: row[DataBaseConstant.lecturerCVColumn],
          main: row[DataBaseConstant.lecturerIsLectureColumn] == 1 ? true:false,
          lectureName: row[DataBaseConstant.lecturerLectureNameColumn],
          imageUrl:  row[DataBaseConstant.lecturerImageColumn],
      );
      MyData.addLecturer(lecturer);
    }
    return true;
  }

  static Future<bool> insertUser(User user) async{
    var myConnection = await connection;
    //insert the user
    var results = await myConnection.query("insert into " + DataBaseConstant.userTableName
        + "(" + DataBaseConstant.userNameColumnString + ", " + DataBaseConstant.userCompanyColumnString + ", " + DataBaseConstant.userRoleColumnString +
        ", " + DataBaseConstant.userEmailColumnString + ") values (?, ?, ?, ?)", [user.fullName, user.company, user.role, user.email]);

    //close the connection
    await myConnection.close();
    return true;
  }

  static Future<void> insertParticipants(User user, String conferenceName) async{
    var myConnection = await connection;
    //insert the user
    var results = await myConnection.query("insert into " + DataBaseConstant.participantsTableName
        + "(" + DataBaseConstant.participantsEmailColumnString + ", " + DataBaseConstant.participantsConferenceNameColumnString +
        ") values (?, ?)", [user.email, conferenceName]);

    //close the connection
    await myConnection.close();
  }

}

///use as interface with the local storage.
class Storage{
  static Future<String> get localPath async{
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<File> get userFile async{
    final path = await localPath;
    return File('$path/user.txt');
  }

  static Future<File> get dataFile async{
    final path = await localPath;
    return File('$path/data.txt');
  }

  static Future<String> get readData async{
    try{
      final file = await dataFile;
      if(!file.existsSync()) file.createSync(recursive: true);
      String body = await file.readAsString();

      return body;
    }catch(e){
      return e.toString();
    }
  }

  static Future<String> get readUser async{
    try{
      final file = await userFile;
      if(!file.existsSync()) {
        file.createSync(recursive: true);
        return null;
      }
        String body = await file.readAsString();
        return body;
    }catch(e){
      return null;
    }
  }

  static Future<File> writeData(String data) async{
    final file = await dataFile;
    if(!file.existsSync()) file.createSync(recursive: true);
    return file.writeAsString("$data");
  }

  static Future<File> writeUser(String data) async{
    final file = await userFile;
    if(!file.existsSync()) file.createSync(recursive: true);
    return file.writeAsString("$data");
  }

  ///get the user from file
  static void loadUser() async{
    //todo: check if empty
    User user = User.fromString(await readUser);
    currentUser = user;
  }

  ///save the user dta to local file
  static void saveUser(User user){
    writeUser(user.toString());
  }

  ///load the save data of conferences
  static void loadData() async{
    //todo: check if empty
    readData.then((result){
      List<String> dataList = result.split("\n");
      String type;
      for(String line in dataList){
        type = line.split(";")[0];
        if(type == ConferenceCard.getDataType) MyData.addConference(ConferenceCard.fromString(line));
        if(type == "Planer"){
          for(ConferenceCard conf in myConferenceCard){
            if(conf.title == line.split(";")[1]){
              myConferenceCard[myConferenceCard.indexOf(conf)].userAddToPlaner = line.split(";")[3]=="true"?true:false;
              break;
            }
          }
        }
        if(type == Lecture.getDataType) MyData.addLecture(Lecture.fromString(line));
        if(type == Lecturer.getDataType) MyData.addLecturer(Lecturer.fromString(line));
      }
    });
  }

  ///save all conferences data
  static void saveData() async{
    String dataString = "";
    for(ConferenceCard conferenceCard in MyData.getConferenceCards){
      dataString += conferenceCard.toString() + "\n";
      dataString += "Planer" + ";" + conferenceCard.title + ";" + (conferenceCard.userAddToPlaner?"true":"false");
    }
    for(Lecture lecture in MyData.getLectureCards){
      dataString += lecture.toString() + "\n";
    }
    for(Lecturer lecturer in MyData.getLecturers){
      dataString += lecturer.toString() + "\n";
    }
    writeData(dataString);
    print("data saved");
  }
}
