class AlgoliaSearchModel {
  String title;
  String description;
  String id;
  String createdBy;
  AlgoliaSearchModel({this.id, this.title, this.description});

  AlgoliaSearchModel.fromSnapshot(
      Map<String, dynamic> data, String objectID, String type) {
    if (type == "User") {
      this.title = data['userName'];
      this.description = data['userEmail'];
    } else {
      this.title = data['title'];
      this.description = data['description'];
    }

    this.id = objectID;
  }
}
