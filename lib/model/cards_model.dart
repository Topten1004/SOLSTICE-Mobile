import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/select_filter_model.dart';

class Media {
  String thumbnail;
  String fileUrl;

  Media({this.thumbnail, this.fileUrl});

  Media.fromJson(Map<String, dynamic> json) {
    thumbnail = json['thumbnail'];
    fileUrl = json['file_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['thumbnail'] = this.thumbnail;
    data['file_url'] = this.fileUrl;
    return data;
  }
}

class CardModel {
  String cardId;
  List<SetNumbers> setNumbers;
  String title;
  String description;
  List<Media> media;
  String type;
  Timestamp timestamp;
  String createdBy;
  List<File> imageFiles = [];
  String importBy;
  bool isSelected = false;
  bool isSelectedSection = false;
  List<String> bodyParts;
  List<SelectFilterModel> categoryList;
  List<SelectFilterModel> subcategoryList;
  List<SelectFilterModel> toolsList;
  List<SelectFilterModel> settingsList;
  List<String> categoryListTitle;
  List<String> subcategoryListTitle;
  List<String> toolsListTitle;
  List<String> settingsListTitle;
  HashMap<File, File> videoFiles;
  int saveCount;
  UserFirebaseModel userFirebaseModel;
  String feedId;

  CardModel(
      {this.cardId,
      this.setNumbers,
      this.title,
      this.description,
      this.media,
      this.type,
      this.timestamp,
      this.imageFiles,
      this.userFirebaseModel,
      this.createdBy,
      this.importBy,
      this.categoryList,
      this.bodyParts,
      this.subcategoryList,
      this.toolsList,
      this.videoFiles,
      this.settingsList,
      this.saveCount,
      this.isSelectedSection,
      this.feedId,
      this.categoryListTitle,
      this.subcategoryListTitle,
      this.toolsListTitle,
      this.settingsListTitle});

  CardModel.fromJson(DocumentSnapshot documentSnapshot) {
    cardId = documentSnapshot.id;
    Map<String, dynamic> json = documentSnapshot.data();

    if (json['set_numbers'] != null) {
      setNumbers = new List<SetNumbers>();
      json['set_numbers'].forEach((v) {
        setNumbers.add(new SetNumbers.fromJson(v));
      });
    }
    title = json['title'];
    // bodyParts = json['body_parts'].cast<String>();
    if (json['body_parts'] != null) {
      bodyParts = new List<String>();
      json['body_parts'].forEach((v) {
        bodyParts.add((v));
      });
    }
    if (json['category_list_title'] != null) {
      categoryListTitle = new List<String>();
      json['category_list_title'].forEach((v) {
        categoryListTitle.add((v));
      });
    }
    if (json['tools_list_title'] != null) {
      toolsListTitle = new List<String>();
      json['tools_list_title'].forEach((v) {
        toolsListTitle.add((v));
      });
    }
    if (json['subcategory_list_title'] != null) {
      subcategoryListTitle = new List<String>();
      json['subcategory_list_title'].forEach((v) {
        subcategoryListTitle.add((v));
      });
    }
    if (json['settings_list_title'] != null) {
      settingsListTitle = new List<String>();
      json['settings_list_title'].forEach((v) {
        settingsListTitle.add((v));
      });
    }
    description = json['description'];
    if (json['media'] != null) {
      media = new List<Media>();
      json['media'].forEach((v) {
        media.add(new Media.fromJson(v));
      });
    }
    type = json['card_type'];
    timestamp = json['timestamp'];
    createdBy = json['created_by'];
    importBy = json['import_by'];
    feedId = json['feed_id'];

    if (json['categories'] != null) {
      categoryList = new List<SelectFilterModel>();
      json['categories'].forEach((v) {
        categoryList.add(new SelectFilterModel.fromJson(v));
      });
    }
    if (json['sub_categories'] != null) {
      subcategoryList = new List<SelectFilterModel>();
      json['sub_categories'].forEach((v) {
        subcategoryList.add(new SelectFilterModel.fromJson(v));
      });
    }
    if (json['tools'] != null) {
      toolsList = new List<SelectFilterModel>();
      json['tools'].forEach((v) {
        toolsList.add(new SelectFilterModel.fromJson(v));
      });
    }
    if (json['settings'] != null) {
      settingsList = new List<SelectFilterModel>();
      json['settings'].forEach((v) {
        settingsList.add(new SelectFilterModel.fromJson(v));
      });
    }
    saveCount = json['save_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.setNumbers != null) {
      data['set_numbers'] = this.setNumbers.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['description'] = this.description;
    if (this.media != null) {
      data['media'] = this.media.map((v) => v.toJson()).toList();
    }
    data['card_type'] = this.type;
    data['timestamp'] = this.timestamp;
    data['created_by'] = this.createdBy;
    data['import_by'] = this.importBy;
    data['body_parts'] = this.bodyParts;
    data['feed_id'] = this.feedId;
    data['category_list_title'] = this.categoryListTitle;
    data['subcategory_list_title'] = this.subcategoryListTitle;
    data['settings_list_title'] = this.settingsListTitle;
    data['tools_list_title'] = this.toolsListTitle;

    if (this.categoryList != null) {
      data['category_list'] = this.categoryList.map((v) => v.toJson()).toList();
    }
    if (this.subcategoryList != null) {
      data['subcategory_list'] =
          this.subcategoryList.map((v) => v.toJson()).toList();
    }
    if (this.toolsList != null) {
      data['tools_list'] = this.toolsList.map((v) => v.toJson()).toList();
    }
    if (this.settingsList != null) {
      data['settings_list'] = this.settingsList.map((v) => v.toJson()).toList();
    }

    data['save_count'] = this.saveCount;
    return data;
  }
}

class SetNumbers {
  String weight;
  String weightInput;
  String unit;
  String unitInput;

  SetNumbers({this.weight, this.weightInput, this.unit, this.unitInput});

  SetNumbers.fromJson(Map<String, dynamic> json) {
    weight = json['weight'];
    weightInput = json['weight_input'];
    unit = json['unit'];
    unitInput = json['unit_input'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['weight'] = this.weight;
    data['weight_input'] = this.weightInput;
    data['unit'] = this.unit;
    data['unit_input'] = this.unitInput;
    return data;
  }
}
