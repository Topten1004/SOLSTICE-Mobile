import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:solstice/utils/constants.dart';

class CreateSection extends StatefulWidget {
  final String title;
   String sectionName;
  CreateSection({this.title, this.sectionName});

  @override
  _CreateSectionState createState() => _CreateSectionState();
}

class _CreateSectionState extends State<CreateSection> {
  TextEditingController sectionNameController = new TextEditingController();

  String newValue = "";

  @override
  Widget build(BuildContext context) {
  
    sectionNameController.text =
        newValue.isEmpty ? widget.sectionName : newValue;
  
    // sectionName = "NewSection";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    onPressed: () => {Navigator.of(context).pop()},
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyTextColor,
                        fontFamily: Constants.openSauceFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black, size: 28),
                    onPressed: () => {Navigator.of(context).pop()},
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: TextField(
                controller: sectionNameController.text.isEmpty
                    ? TextEditingController(text: widget.sectionName)
                    : sectionNameController,
                onChanged: (value) {
                  widget.sectionName = value;
                  newValue = value;
                },
                onSubmitted: (value) {
                  newValue = value;
                },
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                    labelText: 'Name',
                    contentPadding: EdgeInsets.symmetric(horizontal: 3.0),
                    labelStyle: TextStyle(
                        fontSize: 12.0, color: AppColors.liteTextColor)),
                autofocus: true,
              ),
            ),
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
                  newValue = newValue.isEmpty ? widget.sectionName : newValue;

                  if (newValue.trim().isEmpty) {
                    Constants().errorToast(context, "This field is required");
                  } else {
                    Navigator.pop(context, {"sectionName": newValue});
                  }
                },
                color: AppColors.darkTextColor,
                textColor: Colors.white,
                padding: EdgeInsets.all(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(Constants.doneText.toUpperCase(),
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
