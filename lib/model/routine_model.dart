import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/select_filter_model.dart';

class RoutineModel {
  String id;
  List<String> sectionIds;
  String createdBy;
  String importBy;
  Timestamp timestamp;
  String title;
  List<SelectFilterModel> categoryList;
  List<SelectFilterModel> subcategoryList;
  List<SelectFilterModel> toolsList;
  List<SelectFilterModel> settingsList;
  List<SetNumbers> setNumbers;
  String cardType;
  String thumbnail;
  String fileUrl;
  bool expandRoutine = false; // for arrow icon on feed list
  String feedId;
  RoutineModel(
      {this.id,
      this.sectionIds,
      this.createdBy,
      this.importBy,
      this.timestamp,
      this.title,
      this.categoryList,
      this.subcategoryList,
      this.toolsList,
      this.settingsList,
      this.setNumbers,
      this.cardType,
      this.thumbnail,
      this.feedId,
      this.fileUrl});

  RoutineModel.fromJson(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.id;
    Map<String, dynamic> json = documentSnapshot.data();

    // id = json['id'];
    sectionIds = json['section_ids'].cast<String>();
    createdBy = json['created_by'];
    importBy = json['import_by'];
    timestamp = json['timestamp'];
    title = json['title'];
    cardType = json['card_type'];
    thumbnail = json['thumbnail'];
    fileUrl = json['file_url'];
    if (json['category_list'] != null) {
      categoryList = new List<SelectFilterModel>();
      json['category_list'].forEach((v) {
        categoryList.add(new SelectFilterModel.fromJson(v));
      });
    }
    if (json['subcategory_list'] != null) {
      subcategoryList = new List<SelectFilterModel>();
      json['subcategory_list'].forEach((v) {
        subcategoryList.add(new SelectFilterModel.fromJson(v));
      });
    }
    if (json['tools_list'] != null) {
      toolsList = new List<SelectFilterModel>();
      json['tools_list'].forEach((v) {
        toolsList.add(new SelectFilterModel.fromJson(v));
      });
    }
    if (json['settings_list'] != null) {
      settingsList = new List<SelectFilterModel>();
      json['settings_list'].forEach((v) {
        settingsList.add(new SelectFilterModel.fromJson(v));
      });
    }
    if (json['set_numbers'] != null) {
      setNumbers = new List<SetNumbers>();
      json['set_numbers'].forEach((v) {
        setNumbers.add(new SetNumbers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['section_ids'] = this.sectionIds;
    data['created_by'] = this.createdBy;
    data['import_by'] = this.importBy;
    data['timestamp'] = this.timestamp;
    data['title'] = this.title;
    data['card_type'] = this.cardType;
    data['thumbnail'] = this.thumbnail;
    data['file_url'] = this.fileUrl;
    if (this.categoryList != null) {
      data['category_list'] = this.categoryList.map((v) => v.toJson()).toList();
    }
    if (this.subcategoryList != null) {
      data['subcategory_list'] = this.subcategoryList.map((v) => v.toJson()).toList();
    }
    if (this.toolsList != null) {
      data['tools_list'] = this.toolsList.map((v) => v.toJson()).toList();
    }
    if (this.settingsList != null) {
      data['settings_list'] = this.settingsList.map((v) => v.toJson()).toList();
    }
    if (this.setNumbers != null) {
      data['set_numbers'] = this.setNumbers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
 

