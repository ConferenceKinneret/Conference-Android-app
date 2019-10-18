import 'package:flutter/material.dart';
import 'package:flutter_app/RegisterRout.dart';


class LoginRout extends StatelessWidget {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),

      body: SingleChildScrollView(
       child: Center(
        child: Column(
          children: <Widget> [
            buildImage(),
            buildTextField("User name", userNameController),
            buildTextField("Password", passwordController),
            buildLoginButton(context),
            buildRegisterButton(context),
          ],
        ),
      ),
      ),
    );
  }

  Widget buildImage() {
    return Container(
      alignment: AlignmentDirectional.center,
      child: Padding(
        padding: EdgeInsets.only(top: 15, left: 60, right: 60),
        child: Image.network(
            'http://placeimg.com/640/480/any',
          width: 230,
          height: 230,
          ),
      ),
    );
  }

  Widget buildTextField(String text, TextEditingController controller) {
    return Container(
      alignment: AlignmentDirectional.center,
      child: Padding(
        padding: EdgeInsets.only(top: 15, left: 60, right: 60),
        child: TextField(
          controller: controller,
          decoration: new InputDecoration(
              hintText: text
          ),
        ),
      ),
    );
  }

  Widget buildLoginButton(BuildContext context){
    return Container(
      alignment: AlignmentDirectional.center,
      child:
      Center(
        child: RaisedButton(
          child: Text("Login"),
          onPressed: (){
            if(userNameController.text != "" && passwordController.text != ""){
              //if the user or password empty show message
            }else{
              //check user name and password

              //if user name and password compatible, login and go to main rout
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget buildRegisterButton(BuildContext context){
    return Container(
      alignment: AlignmentDirectional.center,
      child:
      Center(
        child: RaisedButton(
          child: Text("Register"),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RegisterRout()
              ),
            );
          },
        ),
      ),
    );
  }
}
