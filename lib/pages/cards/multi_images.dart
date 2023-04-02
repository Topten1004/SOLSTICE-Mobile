import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class MultiImagePage extends StatefulWidget {
  @override
  _MultiImagePageState createState() => _MultiImagePageState();
}

class _MultiImagePageState extends State<MultiImagePage> {
  List<Asset> images = List<Asset>();

  @override
  void initState() {
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   var appBar = AppBar(
  //     backgroundColor: Colors.white,
  //     leading: IconButton(
  //       icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
  //       onPressed: () {},
  //       // onPressed: () => Navigator.of(context).pop(),
  //     ),
  //     elevation: 0,
  //     actions: [
  //       Center(
  //         child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //             child:
  //                 Image.asset("assets/images/help.png", height: 26, width: 26)),
  //       )
  //     ],
  //   );
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     appBar: appBar,
  //     body: Container(
  //       child: GridView.count(
  //         crossAxisCount: 3,
  //         children: List.generate(images.length, (index) {
  //           Asset asset = images[index];
  //           return AssetThumb(
  //             asset: asset,
  //             width: 300,
  //             height: 300,
  //           );
  //         }),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Multi Image Picker - FlutterCorner.com'),
        ),
        body: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("Pick images"),
              onPressed: pickImages,
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                children: List.generate(images.length, (index) {
                  Asset asset = images[index];
                  return AssetThumb(
                    asset: asset,
                    width: 300,
                    height: 300,
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> pickImages() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarTitle: "FlutterCorner.com",
        ),
      );
    } on Exception catch (e) {
    }

    setState(() {
      images = resultList;
    });
  }
}
