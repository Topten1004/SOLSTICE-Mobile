class SelectFilterModel {
  String title;
  String searchTitle = "";
  bool isSelected = false;
  String id;

  SelectFilterModel(this.title, this.isSelected, this.searchTitle, this.id);

  SelectFilterModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    searchTitle = json['search_title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['search_title'] = this.searchTitle;
    data['id'] = this.id;

    return data;
  }
}
