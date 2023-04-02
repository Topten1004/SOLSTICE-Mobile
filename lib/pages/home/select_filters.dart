import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';

class SelectFilterScreen extends StatefulWidget {
  final String filterType;
  final String filterName;
  final List<String> selectedItemList;


  SelectFilterScreen({this.filterType, this.filterName, this.selectedItemList});
  @override
  _SelectFilterScreenState createState() => _SelectFilterScreenState();
}

class _SelectFilterScreenState extends State<SelectFilterScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  bool isBtnEnable = false;
  List<Suggestions> itemsList = new List();

  bool editFields = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if(widget.filterType != null){
      getDataFromFb();
    }

  }


  void getDataFromFb() {
    String filterType = widget.filterType;
    String collectionName = Constants.goalsColl;
    if(filterType == "goals"){
      collectionName = Constants.goalsColl;
    }else if(filterType == "movementType"){
      collectionName = Constants.movementTypeColl;
    }else if(filterType == "sportActivities"){
      collectionName = Constants.sportActivitiesColl;
    }else if(filterType == "equipment"){
      collectionName = Constants.equipmentColl;
    }else if(filterType == "nutrition"){
      collectionName = Constants.nutritionColl;
    }

    else if(filterType == "interests"){
      collectionName =  Constants.InterestsColl;
    }else if(filterType == "occupation"){
      collectionName = Constants.OccupationColl;
    }else if(filterType == "activeInjuries"){
      collectionName = Constants.ActiveInjuriesColl;
    }else if(filterType == "previousInjuries"){
      collectionName = Constants.PreviousInjuriesColl;
    } else if(filterType == "certifications"){
      collectionName = Constants.CertificationsColl;
    }else if(filterType == "coaches"){
      collectionName = Constants.CoachesColl;
    }

    List<String> tempList = new List();

    isLoading = true;
    FirebaseFirestore.instance
        .collection(collectionName)
        .get()
        .then((value) {
      isLoading = false;

      value.docs.forEach((element) {
        tempList.add(element.get("title"));

        setState(() {

        });
      });

      addDataIntoFinalList(tempList);

      //Constants().errorToast(context, "message ${tempList.length}");
    });




    if(mounted)
    setState(() {

    });

  }
  void addDataIntoFinalList(List<String> tempList) {
    if(tempList != null && tempList.length > 0){
      for (int i = 0; i < tempList.length; i++) {
        itemsList.add(Suggestions(tempList[i], false));
      }

      if(widget.selectedItemList != null && widget.selectedItemList.length > 0){
        for (int j = 0; j < itemsList.length; j++) {
            for (int i = 0; i < widget.selectedItemList.length; i++) {
            if(itemsList[j].title == widget.selectedItemList[i]){
              itemsList[j].isSelected = true;
            }
          }
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
        key: _scaffoldkey,
        /* appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Filter Post',
            style: TextStyle(fontSize: 14.0, color: Colors.black),
          ),
          titleSpacing: -10,
          centerTitle: false,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20.0,
              )),
        ),*/
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(20),
                        right: ScreenUtil().setSp(36),
                        top: ScreenUtil().setSp(26),
                        bottom: ScreenUtil().setSp(26)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            padding: EdgeInsets.all(2.5),
                            margin: EdgeInsets.only(left: 10, right: 18),
                            child: SvgPicture.asset(
                              'assets/images/ic_back.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  widget.filterName != null ? widget.filterName : "",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            setState(() {

                              List<String> tempList = new List();
                              for (int i = 0; i < itemsList.length; i++) {
                                if(itemsList[i].isSelected){
                                  tempList.add(itemsList[i].title);
                                }
                              }

                              if(tempList.length > 0){
                                Navigator.of(context).pop({'update': "yes", "returnList": tempList});
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Done",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.titleTextColor,
                                fontFamily: Constants.boldFont,
                                fontSize: ScreenUtil().setSp(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading ?Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor)),
                  ) :SingleChildScrollView(
                    child: Container(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: itemsList.length,
                          primary: false,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            return filterListView(
                                itemsList[index]);
                          },
                        ),
                      )
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget lable(String lable) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          child: Text(
            lable,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontFamily: Constants.boldFont,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }


  Widget filterListView(Suggestions suggestionItem) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {

            setState(() {

              itemSelectionProcess(suggestionItem);

            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(ScreenUtil().setSp(20)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setSp(20),right: ScreenUtil().setSp(10)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            suggestionItem.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.titleTextColor,
                                fontFamily: Constants.semiBoldFont,
                                fontSize: ScreenUtil().setSp(27)),
                          ),

                        ]),
                  ),
                ),
                suggestionItem.isSelected ? Container(
                  width: 24,
                  height: 24,
                  padding: EdgeInsets.all(2.5),
                  child: SvgPicture.asset(
                    Constants.checkIcon,
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),
                ): Container(
                  width: 24,
                  height: 24,
                  padding: EdgeInsets.all(2.5),

                ),

                SizedBox(width: 6,)
              ],
            ),
          ),
        ),
      ],
    );
  }

  void itemSelectionProcess(Suggestions suggestionItem) {
    for (int i = 0; i < itemsList.length; i++) {
      if(itemsList[i].title == suggestionItem.title){
        itemsList[i].isSelected = !suggestionItem.isSelected;
      }
    }
  }




}

class Suggestions {
  String title;
  bool isSelected;
  Suggestions(this.title, this.isSelected);

}
