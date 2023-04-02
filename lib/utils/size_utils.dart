
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solstice/utils/screen_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants.dart';


class Styling {
  Styling._();

  static TextStyle appBarText({Color color, FontWeight fw}) {
    return TextStyle(
      color: color ?? AppColors.blackColor[500],
      fontSize: SizeConfig.textMultiplier < 7.0
          ? 3.3 * SizeConfig.textMultiplier
          : 2.9 * SizeConfig.textMultiplier,
      fontFamily: 'almoniregular',
      fontWeight: fw ?? FontWeight.w600,
    );
  }

  static TextStyle titleText({Color color, FontWeight fw, double height}) {
    return TextStyle(
        color: color ?? AppColors.blackColor[500],
        fontSize: SizeConfig.textMultiplier < 7.0
            ? 2.8 * SizeConfig.textMultiplier
            : 2.4 * SizeConfig.textMultiplier,
        fontWeight: fw ?? FontWeight.w500,
        fontFamily: 'almoniregular',
        height: height ?? 1.2);
  }

  static TextStyle normalText(
      {Color color, FontWeight fw, double letterSpacing , TextDecoration lineThrough}) {
    return TextStyle(
        color: color ?? AppColors.blackColor[500],
        fontSize: SizeConfig.textMultiplier < 7.0
            ? 2.6 * SizeConfig.textMultiplier
            : 2.2 * SizeConfig.textMultiplier,
        fontWeight: fw ?? FontWeight.w400,
        fontFamily: 'almoniregular',
        decoration: lineThrough ?? null,
        letterSpacing: letterSpacing ?? null);
  }

  static TextStyle hugeText(
      {Color color, FontWeight fw, double letterSpacing}) {
    return TextStyle(
        color: color ?? AppColors.blackColor[500],
        fontSize: SizeConfig.textMultiplier < 7.0
            ? 3.5 * SizeConfig.textMultiplier
            : 3.0 * SizeConfig.textMultiplier,
        fontWeight: fw ?? FontWeight.bold,
        letterSpacing: letterSpacing ?? null,
        fontFamily: 'almonibold');
  }

  static TextStyle tinyText({Color color, FontWeight fw}) {
    return TextStyle(
      color: color ?? AppColors.blackColor[500],
      fontSize: SizeConfig.textMultiplier < 7.0
          ? 2.0 * SizeConfig.textMultiplier
          : 2.0 * SizeConfig.textMultiplier,
      fontWeight: fw ?? FontWeight.w500,
      fontFamily: 'almoniregular',);
  }

  static TextStyle priceAndPointsText({Color color, FontWeight fw}) {
    return TextStyle(
        color: color ?? AppColors.blackColor[500],
        fontSize: SizeConfig.textMultiplier < 7.0
            ? 3.3 * SizeConfig.textMultiplier
            : 2.8 * SizeConfig.textMultiplier,
        fontFamily: 'almonibold',
        fontWeight: fw ?? FontWeight.bold);
  }
}

class FontSizes {
  FontSizes._();

  static const double titleFontSize = 16;
  static const double desFontSize = 14;
  static const double AppBarTitleFontSize = 17;
  static const double AppBarDesFontSize = 12;
  static const double diaryLogsFontSize = 14;

}


class InputText {
  InputText._();

  static Text textAppBarInput(String title,
      {TextAlign textAlign,
        TextOverflow textOverflow,
        int maxLines,
        Color color,
        FontWeight fontWeight}) {
    return Text(
      title,
      textAlign: textAlign ?? TextAlign.start,
      overflow: textOverflow ?? TextOverflow.ellipsis,
      maxLines: maxLines ?? 1,
      style: Styling.appBarText(color: color, fw: fontWeight),
    );
  }

  static Text textTitleInput(String title,
      {TextAlign textAlign,
        TextOverflow textOverflow,
        int maxLines,
        Color color,
        FontWeight fontWeight,
        double height}) {
    return Text(
      title,
      textAlign: textAlign ?? TextAlign.start,
      overflow: textOverflow ?? TextOverflow.ellipsis,
      maxLines: maxLines ?? 1,
      style: Styling.titleText(color: color, fw: fontWeight, height: height),
    );
  }

  static Text textHugeInput(String title,
      {TextAlign textAlign,
        TextOverflow textOverflow,
        int maxLines,
        Color color,
        FontWeight fontWeight,
        double height}) {
    return Text(
      title,
      textAlign: textAlign ?? TextAlign.start,
      overflow: textOverflow ?? TextOverflow.ellipsis,
      maxLines: maxLines ?? 1,
      style: Styling.hugeText(color: color, fw: fontWeight),
    );
  }

  static Text textNormalInput(
      String title, {
        TextAlign textAlign,
        TextOverflow textOverflow,
        int maxLines,
        Color color,
        FontWeight fontWeight,
        double letterSpacing,
        TextDecoration lineThrough
      }) {
    return Text(
      title,
      textAlign: textAlign ?? TextAlign.start,
      overflow: textOverflow ?? TextOverflow.ellipsis,
      maxLines: maxLines ?? 1,
      style: Styling.normalText(
          color: color, fw: fontWeight, letterSpacing: letterSpacing, lineThrough: lineThrough),
    );
  }

  static Text textTinyInput(String title,
      {TextAlign textAlign,
        TextOverflow textOverflow,
        int maxLines,
        Color color,
        FontWeight fontWeight}) {
    return Text(
      title,
      textAlign: textAlign ?? TextAlign.start,
      overflow: textOverflow ?? TextOverflow.ellipsis,
      maxLines: maxLines ?? 1,
      style: Styling.tinyText(color: color, fw: fontWeight),
    );
  }

  static Text textPriceAndPointsInput(String title,
      {TextAlign textAlign,
        TextOverflow textOverflow,
        int maxLines,
        Color color,
        FontWeight fontWeight}) {
    return Text(
      title,
      textAlign: textAlign ?? TextAlign.start,
      overflow: textOverflow ?? TextOverflow.ellipsis,
      maxLines: maxLines ?? 1,
      style: Styling.priceAndPointsText(color: color, fw: fontWeight),
    );
  }
}

class TextFieldDecoration {
  TextFieldDecoration._();

  static InputDecoration inputDecoration({String hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.whiteColor[100].withOpacity(0.5),
      contentPadding: EdgeInsets.symmetric(
          vertical: Dimens.height17(), horizontal: Dimens.height20()),
      hintText: hintText ?? "",
      hintStyle: Styling.normalText(color: AppColors.appGreyColor[300]),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(width: 1.2, color: AppColors.appGreyColor[700])),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(width: 1.2, color: AppColors.appGreyColor[700])),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(width: 1.2, color: AppColors.appGreyColor[700])),
      errorStyle: TextStyle(color: Colors.redAccent, fontSize: 11.0),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(width: 1.2, color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(width: 1.2, color: Colors.redAccent)),
    );
  }

  static roundedInputDecoration({String hintText, Color borderColor}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.whiteColor[500],
      suffixIcon: Icon(Icons.search, color: AppColors.appGreyColor[300],),
      contentPadding: EdgeInsets.symmetric(
          vertical: Dimens.height15(), horizontal: Dimens.height20()),
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.appGreyColor[300]),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 1, color: borderColor ?? Colors.white)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 1, color: borderColor ?? Colors.white)),
    );
  }

  static roundedRightDecoration({String hintText, Color borderColor, int hintMaxLines}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.whiteColor[500],
      contentPadding: EdgeInsets.fromLTRB(Dimens.height40(), Dimens.height10(), Dimens.height20(), Dimens.height10()),
      hintText: hintText,
      hintMaxLines: hintMaxLines,
      hintStyle: Styling.normalText(color: AppColors.appGreyColor[300]),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.0), topRight: Radius.circular(30.0)),
          borderSide: BorderSide(width: 1, color: borderColor ?? Colors.white)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.0), topRight: Radius.circular(30.0)),
          borderSide: BorderSide(width: 1, color: borderColor ?? Colors.white)),
    );
  }

  static roundedLeftDecoration({String hintText, Color borderColor, int hintMaxLines}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.whiteColor[500],
      contentPadding: EdgeInsets.fromLTRB(Dimens.height50(), Dimens.height10(), Dimens.height15(), Dimens.height10()),
      hintText: hintText,
      hintMaxLines: hintMaxLines,
      hintStyle: TextStyle(color: AppColors.appGreyColor[300]),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), topLeft: Radius.circular(30.0)),
          borderSide: BorderSide(width: 1, color: borderColor ?? Colors.white)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), topLeft: Radius.circular(30.0)),
          borderSide: BorderSide(width: 1, color: borderColor ?? Colors.white)),
    );
  }
}

class Dimens {
  Dimens._();

  static const double image120 = 45.0;
  static const double image100 = 40.0;
  static const double image70 = 35.0;
  static const double image60 = 30.0;
  static const double image50 = 25.0;
  static const double image40 = 20.0;
  static const double image30 = 17.0;
  static const double image25 = 12.0;
  static const double image22 = 11.0;
  static const double image20 = 8.0;
  static const double image15 = 15.0;
  static const double image10 = 10.0;
  static const double icon03 = 3.0;
  static const double icon04 = 4.0;
  static const double icon05 = 5.0;
  static const double icon06 = 6.0;
  static const double icon07 = 7.0;
  static const double icon10 = 10.0;
  static const double size40 = 4.0;
  static const double size30 = 3.0;
  static const double size25 = 2.5;
  static const double size22 = 2.2;
  static const double size20 = 2.0;
  static const double size17 = 1.7;
  static const double size15 = 1.5;
  static const double size13 = 1.3;
  static const double size12 = 1.2;
  static const double size10 = 1.0;
  static const double size08 = 0.8;
  static const double size06 = 0.7;
  static const double size07 = 0.5;
  static const double size05 = 0.4;
  static const double size02 = 0.15;
  static const double size01 = 0.09;

  static double setImageWidth({double dx}) {
    return dx * SizeConfig.imageSizeMultiplier;
  }

  static double setImageHeight({double dy}) {
    return dy * SizeConfig.imageSizeMultiplier;
  }

  static double setWidth({double dx}) {
    return dx * SizeConfig.widthMultiplier;
  }

  static double setHeight({double dy}) {
    return dy * SizeConfig.heightMultiplier;
  }

  static double iconSize03() {
    return Dimens.icon03 * SizeConfig.imageSizeMultiplier;
  }

  static double iconSize04() {
    return Dimens.icon04 * SizeConfig.imageSizeMultiplier;
  }

  static double iconSize05() {
    return Dimens.icon05 * SizeConfig.imageSizeMultiplier;
  }

  static double iconSize07() {
    return Dimens.icon07 * SizeConfig.imageSizeMultiplier;
  }

  static double iconSize06() {
    return Dimens.icon06 * SizeConfig.imageSizeMultiplier;
  }

  static double iconSize10() {
    return Dimens.icon10 * SizeConfig.imageSizeMultiplier;
  }

  static double height01() {
    return Dimens.size01 * SizeConfig.heightMultiplier;
  }

  static double height02() {
    return Dimens.size02 * SizeConfig.heightMultiplier;
  }

  static double height05() {
    return Dimens.size05 * SizeConfig.heightMultiplier;
  }

  static double height07() {
    return Dimens.size07 * SizeConfig.heightMultiplier;
  }

  static double height08() {
    return Dimens.size08 * SizeConfig.heightMultiplier;
  }
  static double height06() {
    return Dimens.size06 * SizeConfig.heightMultiplier;
  }

  static double height10() {
    return Dimens.size10 * SizeConfig.heightMultiplier;
  }

  static double height12() {
    return Dimens.size12 * SizeConfig.heightMultiplier;
  }

  static double height15() {
    return Dimens.size15 * SizeConfig.heightMultiplier;
  }

  static double height17() {
    return Dimens.size17 * SizeConfig.heightMultiplier;
  }

  static double height20() {
    return Dimens.size20 * SizeConfig.heightMultiplier;
  }
  static double height13() {
    return Dimens.size13 * SizeConfig.heightMultiplier;
  }

  static double height22() {
    return Dimens.size22 * SizeConfig.heightMultiplier;
  }

  static double height25() {
    return Dimens.size25 * SizeConfig.heightMultiplier;
  }

  static double height30() {
    return Dimens.size30 * SizeConfig.heightMultiplier;
  }

  static double height40() {
    return Dimens.size40 * SizeConfig.heightMultiplier;
  }
  static double height50() {
    return Dimens.icon05 * SizeConfig.heightMultiplier;
  }

  static double width01() {
    return Dimens.size01 * SizeConfig.widthMultiplier;
  }

  static double width05() {
    return Dimens.size05 * SizeConfig.widthMultiplier;
  }

  static double width07() {
    return Dimens.size07 * SizeConfig.widthMultiplier;
  }

  static double width08() {
    return Dimens.size08 * SizeConfig.widthMultiplier;
  }

  static double width10() {
    return Dimens.size10 * SizeConfig.widthMultiplier;
  }

  static double width12() {
    return Dimens.size12 * SizeConfig.widthMultiplier;
  }

  static double width15() {
    return Dimens.size15 * SizeConfig.widthMultiplier;
  }

  static double width17() {
    return Dimens.size17 * SizeConfig.widthMultiplier;
  }

  static double width20() {
    return (Dimens.size20 + 2.0) * SizeConfig.widthMultiplier;
  }

  static double width22() {
    return Dimens.size22 * SizeConfig.widthMultiplier;
  }

  static double width25() {
    return Dimens.size25 * SizeConfig.widthMultiplier;
  }

  static double width40() {
    return Dimens.size40 * SizeConfig.widthMultiplier;
  }

  static double imageSize10() {
    return Dimens.image10 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize20() {
    return Dimens.image20 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize22() {
    return Dimens.image22 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize25() {
    return Dimens.image25 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize15() {
    return Dimens.image15 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize30() {
    return Dimens.image30 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize40() {
    return Dimens.image40 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize50() {
    return Dimens.image50 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize60() {
    return Dimens.image60 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize70() {
    return Dimens.image70 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize100() {
    return Dimens.image100 * SizeConfig.imageSizeMultiplier;
  }

  static double imageSize120() {
    return Dimens.image120 * SizeConfig.imageSizeMultiplier;
  }

  static progress() {
    return SizedBox(
      height: Dimens.imageSize20(),
      width: Dimens.imageSize20(),
      child: new CircularProgressIndicator(
        strokeWidth: Dimens.height07(),
        valueColor:
        AlwaysStoppedAnimation<Color>(AppColors.defaultAppColor[500]),
        backgroundColor: AppColors.defaultAppColor[50],
      ),
    );
  }
}
