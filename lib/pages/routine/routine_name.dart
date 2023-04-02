import 'package:flutter/material.dart';
import 'package:solstice/pages/routine/create_routine.dart';
import 'package:solstice/pages/routine/routine_tags.dart';
import 'package:solstice/utils/constants.dart';

import 'create_routine.dart';

class CreateRoutineName extends StatefulWidget {
  final String sharedData;
  CreateRoutineName({this.sharedData});
  @override
  _CreateRoutineNameState createState() => _CreateRoutineNameState();
}

class _CreateRoutineNameState extends State<CreateRoutineName> {
  TextEditingController textEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                Constants.giveRoutineName,
                style: TextStyle(
                    fontSize: 20.0, color: AppColors.darkTextColor, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
                controller: textEditingController,
                onChanged: (value) {},
                textAlign: TextAlign.start,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: Constants.openSauceFont,
                    fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    hintText: 'e.g bicep mass gainer',
                    hintStyle: TextStyle(fontSize: 16.0, color: AppColors.hintColor))),
            SizedBox(
              height: 30,
            ),
            Container(
              color: Colors.transparent,
              margin: EdgeInsets.symmetric(vertical: 20.0),
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed: () {
                  if (textEditingController.text.toString().trim().isEmpty) {
                    Constants().errorToast(context, "This field is required");
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateRoutine(
                                  routineName: textEditingController.text.toString(),
                                  sharedata: widget.sharedData,
                                )));
                  }
                },
                color: AppColors.darkTextColor,
                textColor: Colors.white,
                padding: EdgeInsets.all(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(Constants.next.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        fontFamily: "open_saucesans_regular",
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
