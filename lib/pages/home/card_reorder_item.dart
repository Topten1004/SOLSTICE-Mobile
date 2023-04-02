import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:solstice/model/post_card_model.dart';
import 'package:solstice/pages/views/home_post_list_item.dart';
import 'package:solstice/utils/constants.dart';

enum DraggingMode {
  iOS,
  Android,
}

class CardReorderItem extends StatelessWidget {
  final int index;

  final bool isFirst;
  final bool isLast;

  PostCardModel postCardModel;
  CardReorderItem({this.index, this.isFirst, this.isLast, this.postCardModel});

  final DraggingMode draggingMode =
      Platform.isAndroid ? DraggingMode.Android : DraggingMode.iOS;

  @override
  Widget build(BuildContext context) {
    // return ReorderableItem(
    //   childBuilder: _buildChild,
    //   key: postCardModel.key,
    // );
    return Container(
      child: Card(
        elevation: 5.0,
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          child: Row(
            children: [
              Container(
                  margin: EdgeInsets.only(left: 5.0),
                  height: 55.0,
                  width: 55.0,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: ((postCardModel.image != null &&
                              postCardModel.image.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: postCardModel.image,
                              height: 55.0,
                              width: 55.0,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                  child: SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: new CircularProgressIndicator(
                                  backgroundColor: AppColors.primaryColor,
                                ),
                              )),
                            )
                          : setPostDefaultImage(context)))),
              Expanded(
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            postCardModel.title,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.start,
                            softWrap: true,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10.0, left: 10.0),
                color: Color(0x08000000),
                child: Center(
                  child: Icon(Icons.reorder, color: Color(0xFF888888)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static setPostDefaultImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setSp(370),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
    );
  }
}
