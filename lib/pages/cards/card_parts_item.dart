import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/pages/cards/play_card_video.dart';
import 'package:solstice/pages/feeds/card_feed_item.dart';
import 'package:solstice/utils/constants.dart';

class CardPartsItem extends StatefulWidget {
  final int numberValue;
  final int index;
  final int listSize;
  final String title;
  final Media media;
  CardPartsItem({this.numberValue, this.index, this.listSize, this.media,this.title});
  @override
  _CardPartsItemState createState() => _CardPartsItemState();
}

class _CardPartsItemState extends State<CardPartsItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      height: 21,
                      width: 2.0,
                      color: (widget.index != 0)
                          ? AppColors.viewColor
                          : Colors.white,
                    ),
                    Container(
                      width: 20.0,
                      height: 20.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.bordergrey, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          color: Colors.white),
                      child: Text(
                        '${widget.numberValue}',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.darkTextColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: 21.0,
                      width: 2.0,
                      color: (widget.index < widget.listSize - 1)
                          ? AppColors.viewColor
                          : Colors.white,
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  height: 40,
                  width: 40,
                  child: imageView(context, widget.media.thumbnail, 40, 10.0),
                  margin: EdgeInsets.symmetric(horizontal: 14),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'Part ${widget.numberValue}',
                        style: TextStyle(
                            color: AppColors.darkTextColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '00:00 - 00:30',
                        style: TextStyle(
                            color: AppColors.greyTextColor,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                )
              ],
            ),
          ),
          Container(
              child: SvgPicture.asset(
                Constants.saveIcon,
                fit: BoxFit.cover,
              ),
              height: 20,
              width: 20),
          InkWell(
            onTap: () {
              showPartVideoPlay();
            },
            child: Container(
              margin: EdgeInsets.only(left: 15),
              child: SvgPicture.asset(
                Constants.playBlueIcon,
                fit: BoxFit.cover,
              ),
              height: 25,
              width: 25,
            ),
          )
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
    );
  }

  showPartVideoPlay() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return PlayCardVideo(
          videoFile: widget.media.fileUrl,
          title: widget.title,
          index: widget.numberValue,
        );
      },
    );
  }
}
