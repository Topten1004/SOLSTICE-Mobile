import 'package:flutter/material.dart';
import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/utils/constants.dart';

class TagsItem extends StatelessWidget {
  final SelectFilterModel filterModel;
  TagsItem({this.filterModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: AppColors.bordergrey),
          borderRadius: BorderRadius.all(Radius.circular(30.0))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          filterModel.title,
          style: TextStyle(
              fontSize: 12.0,
              color: AppColors.greyTextColor,
              fontWeight: FontWeight.w400),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
    );
  }
}
