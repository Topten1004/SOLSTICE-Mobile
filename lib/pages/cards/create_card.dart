import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/pages/cards/add_title.dart';
import 'package:solstice/pages/cards/card_camera.dart';
import 'package:solstice/pages/cards/choose_human_body_part.dart';
import 'package:solstice/pages/cards/edit_segment.dart';
import 'package:solstice/pages/cards/numerical_inputs.dart';
import 'package:solstice/utils/constants.dart';

class CreateCardPage extends StatefulWidget {
  final String sharedText;
  CreateCardPage({this.sharedText});
  @override
  _CreateCardState createState() => _CreateCardState();
}

class _CreateCardState extends State<CreateCardPage> {
  List<Asset> images = List<Asset>.empty(growable: true);
  List<File> _files = new List.empty(growable: true);
  List<SetNumbers> setNumbersList = new List.empty(growable: true);
  List<HashMap<File, File>> videoFiles = new List.empty(growable: true);

  String selectedCard = "Video";
  String image = "Image";
  String video = "Video";
  String text = "Text";
  String resultTitle = "";
  String resultDesc = "";
  var urlPattern =
      (r"((https?:www\.)|(https?:\/\/)|(www\.)|(a-zA-Z))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
  File mediaFile;

  @override
  void initState() {
    super.initState();
    addCard();
    if (widget.sharedText != null) {
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child:
                  Image.asset("assets/images/help.png", height: 26, width: 26)),
        )
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15.0),
          height: MediaQuery.of(context).size.height -
              (appBar.preferredSize.height +
                  MediaQuery.of(context).padding.top),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    Constants.createCard,
                    style: TextStyle(
                        fontFamily: "open_saucesans_regular",
                        color: Colors.black,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22.0),
                    child: Text(
                      'Some explaination here about what card \nis and what can user do with it.',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14.0,
                          fontFamily: "open_saucesans_regular"),
                    ),
                  ),
                  Container(
                    child: Text(
                      Constants.chooseCardType,
                      style: TextStyle(
                          fontFamily: "open_saucesans_regular",
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: InkWell(
                                onTap: () {
                                  selectedCard = video;
                                  setState(() {});
                                },
                                child: chooseCard(
                                    video, "assets/images/video.png"))),
                        Expanded(
                            child: InkWell(
                                onTap: () {
                                  selectedCard = image;
                                  setState(() {});
                                },
                                child: chooseCard(
                                    image, "assets/images/Image.png"))),
                        Expanded(
                            child: InkWell(
                                onTap: () {
                                  selectedCard = text;
                                  setState(() {});
                                },
                                child: chooseCard(
                                    text, "assets/images/text.png"))),
                      ],
                    ),
                  ),
                  Container(
                    height: 0.3,
                    color: Colors.black26,
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    Constants.addDetails,
                    style: TextStyle(
                        fontFamily: "open_saucesans_regular",
                        color: Colors.black,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    decoration: new BoxDecoration(
                      boxShadow: [
                        new BoxShadow(
                          color: Color.fromRGBO(18, 40, 73, 0.1),
                          spreadRadius: 0,
                          blurRadius: 25,
                        )
                      ],
                    ),
                    child: Card(
                        margin: EdgeInsets.all(10.0),
                        elevation: 2.0,
                        child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                selectedCard == text
                                    ? Container()
                                    : InkWell(
                                        onTap: () async {
                                          if (selectedCard == video) {
                                            var object = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CardCamera(
                                                          mediaType:
                                                              selectedCard ==
                                                                      video
                                                                  ? 2
                                                                  : 1,
                                                        )));
                                            if (object != null) {
                                              setNumbersList =
                                                  object["numberList"];
                                              videoFiles = object["mediaList"];
                                              mediaFile = videoFiles[0]
                                                  .keys
                                                  .elementAt(0);
                                              setState(() {});
                                            }
                                          } else {
                                            pickImages();
                                          }
                                        },
                                        child: Container(
                                          width: 75,
                                          height: 80,
                                          child: DottedBorder(
                                            borderType: BorderType.RRect,
                                            color: AppColors.primaryColor,
                                            radius: Radius.circular(6),
                                            dashPattern: [3, 3, 3, 3],
                                            strokeWidth: 1.2,
                                            child: Center(
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  width: mediaFile != null &&
                                                          (selectedCard ==
                                                                  image ||
                                                              selectedCard ==
                                                                  video)
                                                      ? 75
                                                      : 24,
                                                  height: mediaFile != null
                                                      ? 80
                                                      : 24,
                                                  padding: EdgeInsets.all(2.5),
                                                  child: mediaFile != null &&
                                                          (selectedCard ==
                                                                  image ||
                                                              selectedCard ==
                                                                  video)
                                                      ? Image.file(
                                                          mediaFile,
                                                          alignment:
                                                              Alignment.center,
                                                          fit: BoxFit.contain,
                                                        )
                                                      : Image.asset(
                                                          selectedCard == image
                                                              ? Constants
                                                                  .imageIcon
                                                              : Constants
                                                                  .videoIcon,
                                                          alignment:
                                                              Alignment.center,
                                                          color: AppColors
                                                              .primaryColor,
                                                          fit: BoxFit.contain,
                                                        )),
                                            ),
                                          ),
                                        ),
                                      ),
                                Expanded(
                                    child: Container(
                                  margin: EdgeInsets.only(right: 15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          resultTitle = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddTitle(Constants
                                                          .viewTitle)));
                                          setState(() {});
                                        },
                                        child: Container(
                                            height: 30.0,
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            margin: EdgeInsets.only(
                                                top: 10.0,
                                                left: 15.0,
                                                bottom: 5.0),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                border: Border.all(
                                                  color: AppColors.lightBlue,
                                                ),
                                                color: AppColors.lightBlue),
                                            child: Text(
                                              resultTitle != null &&
                                                      resultTitle != ""
                                                  ? resultTitle
                                                  : Constants.addTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color:
                                                      AppColors.primaryColor),
                                            )),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          resultDesc = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddTitle(
                                                          Constants.viewDesc)));
                                          setState(() {});
                                        },
                                        child: Container(
                                            height: 30.0,
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            margin: EdgeInsets.only(
                                                top: 5.0,
                                                left: 15.0,
                                                bottom: 10.0),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                border: Border.all(
                                                  color: AppColors.lightBlue,
                                                ),
                                                color: AppColors.lightBlue),
                                            child: Text(
                                              resultDesc != null &&
                                                      resultDesc != ""
                                                  ? resultDesc
                                                  : widget.sharedText != null &&
                                                          widget.sharedText !=
                                                              ""
                                                      ? widget.sharedText
                                                      : Constants
                                                          .addDescription,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color:
                                                      AppColors.primaryColor),
                                            )),
                                      ),
                                      // GridView.count(
                                      //   crossAxisCount: 3,
                                      //   children: List.generate(images.length,
                                      //       (index) {
                                      //     Asset asset = images[index];
                                      //     return AssetThumb(
                                      //       asset: asset,
                                      //       width: 300,
                                      //       height: 100,
                                      //     );
                                      //   }),
                                      // ),
                                    ],
                                  ),
                                ))
                              ],
                            ))),
                  ),
                ],
              ),
              Container(
                color: Colors.transparent,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () async {
                    if (checkValidation()) {
                      if (selectedCard == text) {
                        var object = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NumericalInputsPage(
                                      showAppBar: true,
                                    )));
                        if (object != null) {
                          setNumbersList = object["numericInputs"];
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChooseHumanBodyPage(
                                      isEditableFields: true,
                                      title: resultTitle,
                                      description: resultDesc,
                                      cardType: selectedCard,
                                      files: _files,
                                      mediaList: videoFiles,
                                      numbersList: setNumbersList,
                                    )));
                        }
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChooseHumanBodyPage(
                                      isEditableFields: true,
                                      title: resultTitle,
                                      description: resultDesc,
                                      cardType: selectedCard,
                                      files: _files,
                                      mediaList: videoFiles,
                                      numbersList: setNumbersList,
                                    )));
                      }
                    }
                  },
                  color: AppColors.darkTextColor,
                  textColor: Colors.white,
                  padding: EdgeInsets.all(12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(Constants.next.toUpperCase(),
                        style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: "open_saucesans_regular",
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool checkValidation() {
    if (resultTitle.toString().trim().isEmpty) {
      Constants().errorToast(context, "Please add title");
      return false;
    } else if (resultDesc.toString().trim().isEmpty) {
      Constants().errorToast(context, "Please add description");
      return false;
    } else if (selectedCard == image && mediaFile == null) {
      Constants().errorToast(context, "Please add image");
      return false;
    } else if (selectedCard == video && mediaFile == null) {
      Constants().errorToast(context, "Please add video");
      return false;
    }
    return true;
  }

  //If needed TextFormField
  // TextFormField(
  //                                     decoration: InputDecoration(
  //                                         border: InputBorder.none,
  //                                         contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
  //                                         hintText: Constants.addDescription,
  //                                         hintStyle: TextStyle(
  //                                             fontSize: 14.0,
  //                                             color: AppColors.primaryColor),
  //                                         labelStyle: TextStyle(
  //                                             fontSize: 14.0,
  //                                             color: AppColors.primaryColor),

  //                                         ),
  //                                     style: TextStyle()),

  Widget chooseCard(String cardTitle, icon) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        border: Border.all(
          color: selectedCard == cardTitle
              ? AppColors.cardColor
              : AppColors.cardColor,
        ),
        color: selectedCard == cardTitle ? AppColors.cardColor : Colors.white,
      ),
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset(icon,
                height: 22,
                width: 22,
                color: selectedCard == cardTitle
                    ? Colors.white
                    : AppColors.cardColor),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 15.0,
            ),
            child: Text(
              cardTitle,
              style: TextStyle(
                  fontFamily: "open_saucesans_regular",
                  color: selectedCard == cardTitle
                      ? Colors.white
                      : Colors.lightBlue,
                  fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  bool validateUrl(String hyperlink) {
    var match = new RegExp(urlPattern, caseSensitive: false);

    return match.hasMatch(hyperlink);
  }

  Future<void> pickImages() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: false,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarTitle: "Select Images",
        ),
      );
    } on Exception catch (e) {
    }

    // setState(() {
    images = resultList;
    getAbsolutePath();
    // });
  }

  Future<File> getImageFileFromAssets(Asset asset) async {
    final byteData = await asset.getByteData();

    final tempFile =
        File("${(await getTemporaryDirectory()).path}/${asset.name}");
    final file = await tempFile.writeAsBytes(
      byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );

    return file;
  }

  getAbsolutePath() async {
    List<File> files = [];
    for (Asset asset in images) {
      final filePath = await getImageFileFromAssets(asset);
      files.add(filePath);
    }

    if (!mounted) return;
    setState(() {
      _files = files;
      mediaFile = files[0];
      if (_files != null && _files.length > 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditSegmentPage(
                      imageFiles: _files,
                      viewType: "Image",
                      videoFiles: [],
                    ))).then((value) {
          if (value != null) {
            setNumbersList = value["numberList"];
            // numericalInputsList = value;
          }
        });
      }
    });
  }

  void addCard() {
    // List<SetNumbers> setNumbersList = new List.empty(growable: true);
    // List<Media> mediaList = new List.empty(growable: true);
    // List<String> toolsList = new List.empty(growable: true);
    // // List<Category> ls2 = new List.empty(growable: true);
    // // List<Media> ls2 = new List.empty(growable: true);

    // SetNumbers setModel = new SetNumbers("44", "Reps", "55", "Kilos/Arms");
    // SetNumbers setModel1 = new SetNumbers("55", "Inches", "88", "Yards");
    // Media mediaModel = new Media("", "");
    // Media mediaModel1 = new Media("", "");
    // setNumbersList.add(setModel);
    // setNumbersList.add(setModel1);
    // mediaList.add(mediaModel);
    // mediaList.add(mediaModel1);
    // toolsList.add("EueouiW4Ua2Llm5xlplg");

    // CardModel cardModel = new CardModel(
    //   title: "CardText",
    //   type: "Image",
    //   description: "Test Description",
    //   bodyParts: [],
    //   settings: [],
    //   categories: [],
    //   tools: toolsList,
    //   subCategories: [],
    //   setNumbers: setNumbersList,
    //   media: mediaList,
    // );

    // FirebaseFirestore.instance
    //     .collection("Cards")
    //     .add(cardModel.toJson())
    //     .then((value) {
    // });
  }
}
