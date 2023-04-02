class CardTitleMainModel {
  String titleHeading;
  List<CardTitleModel> titleList;
  CardTitleMainModel({this.titleHeading, this.titleList});
}

class CardTitleModel {
  String title;
  String id;
  bool isTitleSelected = false;
  CardTitleModel({this.title, this.id, this.isTitleSelected});
}
