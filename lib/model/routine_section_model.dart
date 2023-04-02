import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solstice/model/cards_model.dart';

class RoutineSectionModel {
  List<String> cardIds;
  String sectionId;
  Timestamp timestamp;
  String createdBy;
  String title;
  List<CardModel> cardList = new List();
  CardModel cardModel;
  String importBy;
  bool isEditMode = false;
  bool isExpanded = false;
  bool isSelected = false;
  bool showCards = false;
  int selectedIndex = 0;

  RoutineSectionModel(
      {this.cardIds,
      this.sectionId,
      this.timestamp,
      this.cardList,
      this.createdBy,
      this.cardModel,
      this.title,
      this.selectedIndex,
      this.isEditMode,
      this.importBy,
      this.isSelected});

  RoutineSectionModel.fromJson(DocumentSnapshot documentSnapshot) {
    sectionId = documentSnapshot.id;
    Map<String, dynamic> json = documentSnapshot.data();

    cardIds = json['card_ids'].cast<String>();

    timestamp = json['timestamp'];
    createdBy = json['created_by'];
    title = json['title'];
    importBy = json['import_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_ids'] = this.cardIds;
    data['section_id'] = this.sectionId;
    data['timestamp'] = this.timestamp;
    data['title'] = this.title;
    data['created_by'] = this.createdBy;
    data['import_by'] = this.importBy;
    return data;
  }
}
