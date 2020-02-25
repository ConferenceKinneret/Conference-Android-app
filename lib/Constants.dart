import 'dart:collection';


class Constants{
  static const String Register = 'Register';
  static const String About = 'About';

  static const List<String> choices = <String>[Register, About];

  ///use for about rout
  static const String aboutText = "We are students from the Kinneret Academic College who have been asked to build a conference management and management systemthat is carried out at the college.\n"
      + "And that the system can be used by any organization and not necessarily just the college,\n"
      + "so we chose to build the system as a web system for building and managing the advanced conference in Angular, and an Android application to be used for viewing at conferences";

  static const double imageW = 100;
  static const double imageH = 75;
  static const String defaultImage = 'images/kinneretLogo.jpg';
}

class ConferenceCard{
  final String title;       //conference name
  final String description;
  final String place;       //location
  final String date;
  final String imageUrl;
  final List<Lecture> lectures;
  final List<Lecture> parallelLectures;

  //indicator to check if the user add register to the conference
  bool userAddToPlaner = false;

  ConferenceCard(String title, String description, String image, String place, String date, bool userAddToPlaner):
    this.title = title,
    this.description =description,
    this.imageUrl = image,
    this.place = place,
    this.date = date,
    this.lectures = new List(),
    this.parallelLectures = new List(),
    this.userAddToPlaner = userAddToPlaner;

  ///sort the lectures by start time
  void sortLectures(){
    if(this.lectures == null || this.lectures.length < 2) return;
    List<Lecture> newLectures = new List();
    List<Lecture> tempList = new List();
    tempList.addAll(this.lectures);
    Lecture minLect;
    while(tempList.length != 0){
      minLect = null;
      //get the minimal time
      for(Lecture lecture in tempList){
        if(minLect == null) minLect = lecture;
        if(minLect.hourOfStart() >= lecture.hourOfStart())
          if(minLect.minuteOfStart() > lecture.minuteOfStart()) minLect = lecture;
          else if(minLect.hourOfStart() > lecture.hourOfStart()) minLect = lecture;
      }
      newLectures.add(minLect);
      tempList.remove(minLect);
    }
    //remove all from list and add all from sorted list
    this.lectures.removeRange(0, this.lectures.length);
    for(Lecture lecture in newLectures){
      lecture.removeLecturersDuplications();
    }
    this.lectures.addAll(newLectures);
  }

  String toString(){
    String userAddToPlanerString;
    if(userAddToPlaner) userAddToPlanerString = "true";
    else userAddToPlanerString = "false";
    return  getDataType + ";" + title + ";" + description + ";" + place==null?" ":place + ";" + date + ";" + imageUrl + ";" + userAddToPlanerString;
  }

  static String get getDataType{ return "Conference"; }

  static ConferenceCard fromString(String conferenceCardString){
    List<String> splitedconferenceCardString = conferenceCardString.split(";");
    if(splitedconferenceCardString[0] != "Conference") return null;
    String title = splitedconferenceCardString[1];
    String description = splitedconferenceCardString[2];
    String place = splitedconferenceCardString[3];
    if(place == " ") place = null;
    String date = splitedconferenceCardString[4];
    String image = splitedconferenceCardString[5];
    bool userAddToPlaner = splitedconferenceCardString[6]=="true"?true:false;
    return new ConferenceCard(title, description, image, place, date, userAddToPlaner);
  }

  String getMinLectureStartTime(){
    Lecture minLect = null;
    //get the minimal time
    for(Lecture lecture in this.lectures){
      if(minLect == null) minLect = lecture;
      if(minLect.hourOfStart() >= lecture.hourOfStart())
        if(minLect.minuteOfStart() > lecture.minuteOfStart()) minLect = lecture;
        else if(minLect.hourOfStart() > lecture.hourOfStart()) minLect = lecture;
    }
    print("min: " + minLect.startTime);
    if(minLect.startTime.split(":")[0].length < 2) return "0" + minLect.startTime;
    return minLect.startTime;
  }

  String getMaxLectureEndTime(){
    Lecture maxLect = null;
    //get the minimal time
    for(Lecture lecture in this.lectures){
      if(maxLect == null) maxLect = lecture;
      if(maxLect.hourOfEnd() < lecture.hourOfEnd())
        if(maxLect.minuteOfEnd() < lecture.minuteOfStart()) maxLect = lecture;
        else if(maxLect.hourOfEnd() < lecture.hourOfEnd()) maxLect = lecture;
    }
    print("max: " + maxLect.endTime);
    return maxLect.endTime;
  }

  void toggleUserAddToPlaner(){ this.userAddToPlaner = !userAddToPlaner;}

}

class Lecture{
  Lecture({this.conferenceName, this.lectureName, this.startTime, this.endTime, this.lecturers, this.place, this.description, this.file});
  final String lectureName;
  final String startTime;
  final String endTime;
  final List<Lecturer> lecturers;
  final String place;      //class
  final String description;
  final String file; //todo: implement
  final String conferenceName;

  void removeLecturersDuplications(){
    if(lecturers == null || lecturers.length < 2) return;

    final newList = new LinkedHashSet<Lecturer>(
        equals: (Lecturer e1, Lecturer e2) => e1.name == e2.name,
        hashCode: (Lecturer e) => e.name.hashCode);

    newList.addAll(lecturers);

    lecturers.removeRange(0, lecturers.length);
    lecturers.addAll(newList);
  }

  /// get string in format HH:MM and return the hour as int
  int hourOfStart(){
    return int.parse(this.startTime.split(":")[0]);
  }

  /// get string in format HH:MM and return the minutes as int
  int minuteOfStart(){
    return int.parse(this.startTime.split(":")[1]);
  }

  /// get string in format HH:MM and return the hour as int
  int hourOfEnd(){
    return int.parse(this.endTime.split(":")[0]);
  }

  /// get string in format HH:MM and return the minutes as int
  int minuteOfEnd(){
    return int.parse(this.endTime.split(":")[1]);
  }

  String toString(){
    String lectureString = getDataType + ";" + lectureName + ";" + startTime + ";" + endTime + ";" + place + ";" + description + ";";
    if(file == null) lectureString += "; ;";
    else lectureString += ";" + file + ";";
    lectureString += conferenceName;
    return lectureString;
  }

  static String get getDataType {return "Lecture";}

  static Lecture fromString(String lectureString){
    List<String> splitedLectureString = lectureString.split(";");
    if(splitedLectureString[0] != "Lecture") return null;
    String lectureName = splitedLectureString[1];
    String startTime = splitedLectureString[2];
    String endTime = splitedLectureString[3];
    String place = splitedLectureString[4];
    String description = splitedLectureString[5];
    String file = splitedLectureString[6];
    if(file == " ") file = null;
    String conferenceName = splitedLectureString[7];
    Lecture lecture = new Lecture(lectureName: lectureName, startTime: startTime, endTime: endTime, place: place, description: description, lecturers: [], file: file, conferenceName: conferenceName);
    return lecture;
  }
}

class Lecturer{
  Lecturer({this.name, this.company, this.cv, this.role, this.main, this.lectureName, this.imageUrl});
  final String name;
  final String company;
  final String cv;
  final String role;
  final bool main; //is it main lecturer
  final String lectureName;
  final String imageUrl;

  String toString(){
    String isMain = (main==true)?"1":"0";
    return getDataType + ";" + name + ";" + company + ";" + cv + ";" + role + ";" + isMain + ";" + lectureName + ";" + imageUrl;
  }

  static String get getDataType {return "Lecturer";}

  static Lecturer fromString(String lecturerString){
    List<String> splitedLecturerString = lecturerString.split(";");
    if(splitedLecturerString[0] != "Lecturer") return null;
    String name = splitedLecturerString[1];
    String company = splitedLecturerString[2];
    String cv = splitedLecturerString[3];
    String role = splitedLecturerString[4];
    bool main = splitedLecturerString[5]=="1"?true:false;
    String lectureName = splitedLecturerString[6];
    String imageUrl = splitedLecturerString[7];
    Lecturer lecturer = new Lecturer(name: name, company: company, cv: cv, role: role, main: main, lectureName: lectureName, imageUrl: imageUrl);
    return lecturer;
  }
}

class User{
  User({this.fullName, this.company, this.role, this.email});
  final String email;
  final String fullName;
  final String company;
  final String role;

  @override
  String toString() {
    String userString = email + ";" + fullName + ";" + company + ";" + role;
    return userString;
  }

  static User fromString(String userString){
    if(userString == null || userString == "") return null;
    List<String> splitedString = userString.split(";");
    if(splitedString.length < 3) return null;
    String email    = splitedString[0];
    String fullName = splitedString[1];
    String company  = splitedString[2];
    String role     = splitedString[3];
    return new User(fullName: fullName, company: company, role: role, email: email);
  }
}

///table names and columns numbers to get data from the database
class DataBaseConstant{
  //conference
  static const String conferenceTableName = "tblconference";
  static const int conferenceNameColumn = 0;
  static const int conferenceLocationColumn = 1;
  static const int conferenceDateColumn = 2;
  static const int conferenceDescriptionColumn = 3;
  static const int conferencePublishColumn = 5;
  static const int conferenceImageColumn = 6;

  //Lecturer
  static const String lecturerTableName = "tblauthors";
  static const int lecturerNameColumn = 0;
  static const int lecturerCompanyColumn = 1;
  static const int lecturerRoleColumn = 2;
  static const int lecturerCVColumn = 3;
  static const int lecturerIsLectureColumn = 4;
  static const int lecturerImageColumn = 5;
  static const int lecturerLectureNameColumn = 6;

  //Lecture
  static const String lectureTableName = "tbllecture";
  static const int lectureNameColumn = 0;
  static const int lectureStartColumn = 1;
  static const int lectureEndColumn = 2;
  static const int lectureDescriptionColumn = 3;
  static const int lectureLocationColumn = 4;
  static const int lectureFileColumn = 5;
  static const int lectureConferenceNameColumn = 6;

  //conference user
  static const String userTableName = "tblconferenceuser";
  static const int userNameColumn = 1;
  static const int userPasswordColumn = 2;
  static const int userCompanyColumn = 3;
  static const int userRoleColumn = 4;
  static const int userEmailColumn = 5;
  //conference user as strings
  static const String userNameColumnString = "FullName";
  static const String userPasswordColumnString = "Password";
  static const String userCompanyColumnString = "Company";
  static const String userRoleColumnString = "Role";
  static const String userEmailColumnString = "Email";

  //participants
  static const String participantsTableName = "tblparticipants";
  static const int participantsEmailColumn = 1;
  static const int participantsConferenceNameColumn = 2;
  static const int participantsLectureNameColumn = 3;
  //participants as strings
  static const String participantsEmailColumnString = "UserEmail";
  static const String participantsConferenceNameColumnString = "ConferenceName";
  static const String participantsLectureNameColumnString = "LectureName";
}