import 'package:flutter/material.dart' ;
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/onboardingflow/intrests_screen.dart' ;
import 'package:solstice/utils/constants.dart' ;

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({Key key}) : super(key : key) ;

  _ChangePasswordForm createState() => _ChangePasswordForm() ;
}

class _ChangePasswordForm extends State<ChangePasswordForm> {
  TextEditingController newPasswordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>() ;

  bool showNewPassword = false ;
  bool showConfirmPassword = false ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget build(BuildContext context){
    var appBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
        // onPressed: () {},
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0,
      actions: [
        Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/help.png", height: 26, width: 26)),
        )
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      key : _scaffoldKey,
      body : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 33,
              child: Image(image: AssetImage(Utils.solsciteImage)),
            ),
            Container(
              margin : EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: Text(
                "Create a New Password",
                style: TextStyle(
                  fontFamily: Utils.fontfamilyInter,
                  fontSize: 25,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top : 20),
              padding : EdgeInsets.only(left : 40, right: 40),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: Text(
                "Your password must be different from",
                style: TextStyle(
                  color : Colors.black45,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top : 5),
              padding : EdgeInsets.only(left : 40, right: 40),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: Text(
                "previously used password.",
                style: TextStyle(
                  color : Colors.black45,
                ),
              ),
            ),
            SizedBox(
              height : 40
            ),
            Container(
              margin: EdgeInsets.only(top : 20),
              padding : EdgeInsets.only(left : 20, right: 20),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: TextField(
                  obscureText: showNewPassword ? false : true,
                  controller: newPasswordController,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {

                    setState(() {});
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText : "New password",
                    hintText: 'New password',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: IconButton(
                        icon: Icon(!showNewPassword ? Icons.remove_red_eye : Icons.visibility_off),
                        // onPressed: () {},
                        onPressed: () => setState(() {
                          showNewPassword = !showNewPassword ;
                        })
                      ),
                    ),
                  )),
            ),
            SizedBox(
              height : 20
            ),
            Container(
              margin: EdgeInsets.only(top : 20),
              padding : EdgeInsets.only(left : 20, right: 20),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: TextField(
                  obscureText: showConfirmPassword ? false : true,
                  controller: confirmPasswordController,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {

                    setState(() {});
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Confirm password",
                    hintText: 'Confirm password',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: IconButton(
                        icon: Icon(!showConfirmPassword ? Icons.remove_red_eye : Icons.visibility_off),
                        // onPressed: () {},
                        onPressed: () => setState(() {
                          showConfirmPassword = !showConfirmPassword ;
                        })
                      ),
                    ),
                  )),
            ),
            SizedBox(height: 80),
            InkWell(
              onTap: () {
                // if(newPasswordController.text.toString() != confirmPasswordController.text.toString()) {
                //   Constants().errorToast(context, "The passwords do not match.");
                // } else
                  Navigator.push(context, MaterialPageRoute(builder: (context) => IntrestsScreen()));
              },
              child: Container(
                  height: 56,
                  width: MediaQuery.of(context).size.width * 0.90,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xff283646).withOpacity(0.32),
                            blurRadius: 3.0,
                            spreadRadius: 3),
                      ],
                      color: Color(0xFF283646)),
                  child: Center(
                      child: Utils.text(
                          'Confirm Password Reset', Utils.fontfamily, Color(0xFFFFFFFF), FontWeight.w400, 20))),
            ),
          ],
        ),
      )
    );
  }
}