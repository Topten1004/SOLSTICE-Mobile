class NumericalInputsModel {
  String repsCount;
  String repsUnit;
  String weightCount;
  String weightUnit;
  String selectedIndexId;
  String tempWeightTitle;
  String tempRepTitle;

  NumericalInputsModel data;

  NumericalInputsModel(
      this.repsCount,
      this.repsUnit,
      this.weightCount,
      this.weightUnit,
      this.selectedIndexId,
      this.tempRepTitle,
      this.tempWeightTitle);

  NumericalInputsModel.fromJson(Map<String, dynamic> json) {
    weightCount = json['weightCount'].toString();
    weightUnit = json['weightUnit'].toString();
    selectedIndexId = json['selectedIndexId'].toString();
    tempRepTitle = json['tempTitle'].toString();
    tempWeightTitle = json['tempWeightTitle'].toString();

    if (json['data'] != null) {
      data = NumericalInputsModel.fromJson(json['data']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['selectedIndexId'] = this.selectedIndexId;
    // data['tempTitle'] = this.selectedIndexId;

    if (this.data != null) {
      data['data'] = this.data;
    }
    return data;
  }
}
