import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/model/groups/groups_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';

class ShareToGroup extends StatefulWidget {
  String feedId;
  ShareToGroup({this.feedId});

  @override
  _ShareToGroupState createState() => _ShareToGroupState();
}

class _ShareToGroupState extends State<ShareToGroup> {
  String selectedValue = "";
  List<TabsModel> GroupsTabsList = new List<TabsModel>();
  var selectedTab = "Private";
  List<GroupsFireBaseModel> publicGroups = new List.empty(growable: true);
  List<GroupsFireBaseModel> privateGroups = new List.empty(growable: true);

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    setDefaultList();

    getPrivateGroups();
    getPublicGroups();
  }

  void getPublicGroups() {
    publicGroups.clear();
    FirebaseFirestore.instance
        .collection(Constants.groupsFB)
        //.where('created_by', isEqualTo: globalUserId)
        .orderBy('created_at', descending: true)
        .where("is_public", isEqualTo: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        GroupsFireBaseModel message = GroupsFireBaseModel.fromSnapshot(element);
        publicGroups.add(message);
        setState(() {});
      });
    });
  }

  void getPrivateGroups() {
    privateGroups.clear();
    FirebaseFirestore.instance
        .collection(Constants.groupsFB)
        //.where('created_by', isEqualTo: globalUserId)
        .orderBy('created_at', descending: true)
        .where("is_public", isEqualTo: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        GroupsFireBaseModel message = GroupsFireBaseModel.fromSnapshot(element);
        privateGroups.add(message);
        setState(() {});
      });
    });
  }

  // set tabs
  void setDefaultList() {
    GroupsTabsList.add(new TabsModel("Private", true));
    GroupsTabsList.add(new TabsModel("Public", false));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);

    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.black, size: 24),
                      onPressed: () => {Navigator.of(context).pop()},
                    ),
                    right: 0,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        Constants.chooseGroup,
                        style: TextStyle(
                            fontSize: 14.0, color: AppColors.lightGreyColor),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                margin: EdgeInsets.only(
                    left: ScreenUtil().setSp(36),
                    bottom: ScreenUtil().setSp(16)),
                height: ScreenUtil().setSp(54),
                child: ListView.builder(
                  itemCount: GroupsTabsList == null ? 0 : GroupsTabsList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      //highlightColor: Colors.red,
                      splashColor: AppColors.primaryColor,
                      onTap: () {
                        setState(() {
                          GroupsTabsList.forEach(
                              (element) => element.isSelected = false);
                          GroupsTabsList[index].isSelected = true;
                          selectedTab = GroupsTabsList[index].tabTitle;
                          if (selectedTab == "Private") {
                            getPrivateGroups();
                          } else {
                            getPublicGroups();
                          }
                          //selectedLevel = levelDataList[index].type;
                        });
                      },
                      child: new TabListItem(GroupsTabsList[index]),
                    );
                  },
                ),
              ),
              Visibility(
                visible: selectedTab == "Private" ? true : false,
                child: privateGroupListing(),
              ),
              Visibility(
                visible: selectedTab == "Private" ? false : true,
                child: publicGroupListing(),
              ),
              SizedBox(
                height: 3,
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
                    if (selectedValue == "") {
                      Constants().errorToast(context, "Please select one item");
                    } else {
                      // Navigator.pop(context, {"sectionName": sectionName});
                      shareToFeed(context);
                    }
                  },
                  color: AppColors.darkTextColor,
                  textColor: Colors.white,
                  padding: EdgeInsets.all(12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(Constants.finish.toUpperCase(),
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
        );
      },
    );
  }

  // private group listing
  Widget privateGroupListing() {
    return Flexible(
        child: privateGroups.length > 0
            ? ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      reverse: false,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Container(
                          child: Column(
                            children: [
                              Container(
                                height: 1.0,
                                color: AppColors.viewLineColor,
                              ),
                              InkWell(
                                onTap: () {
                                  for (int j = 0;
                                      j < privateGroups.length;
                                      j++) {
                                    privateGroups[j].isSelected = false;
                                  }

                                  privateGroups[index].isSelected = true;
                                  selectedValue = privateGroups[index].id;
                                  setState(() {});
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 3.0),
                                              child: Text(
                                                privateGroups[index].title,
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors
                                                        .darkTextColor),
                                              )),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 3.0),
                                              child: Text(
                                                privateGroups[index]
                                                    .description,
                                                style: TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors
                                                        .lightGreyColor),
                                              ))
                                        ],
                                      )),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Center(
                                        child: Image.asset(
                                          privateGroups[index].isSelected
                                              ? Constants.circleCheckIcon
                                              : Constants.uncheckIcon,
                                          height: 30.0,
                                          width: 30.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: privateGroups.length,
                      //controller: listScrollController,
                    ),
                  ),
                ],
              )
            : Center(
                child: Container(
                  child: Text(
                    Constants.noDataFound.toString(),
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontFamily: Constants.regularFont,
                        height: 1.3,
                        letterSpacing: 0.8),
                  ),
                ),
              ));
  }

  // public group listing prcess
  Widget publicGroupListing() {
    return Flexible(
        child: publicGroups.length > 0
            ? ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      reverse: false,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Container(
                          child: Column(
                            children: [
                              Container(
                                height: 1.0,
                                color: AppColors.viewLineColor,
                              ),
                              InkWell(
                                onTap: () {
                                  for (int j = 0;
                                      j < publicGroups.length;
                                      j++) {
                                    publicGroups[j].isSelected = false;
                                  }

                                  publicGroups[index].isSelected = true;
                                  selectedValue = publicGroups[index].id;
                                  setState(() {});
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 3.0),
                                              child: Text(
                                                publicGroups[index].title,
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors
                                                        .darkTextColor),
                                              )),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 3.0),
                                              child: Text(
                                                publicGroups[index].description,
                                                style: TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors
                                                        .lightGreyColor),
                                              ))
                                        ],
                                      )),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Center(
                                        child: Image.asset(
                                          publicGroups[index].isSelected
                                              ? Constants.circleCheckIcon
                                              : Constants.uncheckIcon,
                                          height: 30.0,
                                          width: 30.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: publicGroups.length,
                      //controller: listScrollController,
                    ),
                  ),
                ],
              )
            : Center(
                child: Container(
                  child: Text(
                    Constants.noDataFound.toString(),
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontFamily: Constants.regularFont,
                        height: 1.3,
                        letterSpacing: 0.8),
                  ),
                ),
              ));
  }

  shareToFeed(context) async {
    FirebaseFirestore.instance
        .collection(Constants.groupsFB)
        .doc(selectedValue)
        .update({
      "post_ids": FieldValue.arrayUnion([widget.feedId])
    }).then((value) {
      // Constants().successToast(context, "Feed shared to group");
      Navigator.pop(context, {"finish": "yes"});
    }).catchError((onError) {
    });
  }
}
