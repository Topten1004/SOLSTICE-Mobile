class PostFilterModel {
  String equipment;
  String movementNutrition;
  String movementType;
  String sportsActivity;
  String goal;
  String bodyPart;
  List<String> bodyPartArray;
  String link;
  String people;
  PostFilterModel(
      {this.goal,
      this.bodyPart,
        this.bodyPartArray,
      this.movementType,
      this.sportsActivity,
      this.equipment,
      this.link,
      this.movementNutrition,
      this.people});

  Map toMap() {
    Map<String, dynamic> map = {
      "goal": this.goal,
      "body_part": this.bodyPart,
      "bod_part_array": this.bodyPartArray,
      "movement_type": this.movementType,
      "sports_activity": this.sportsActivity,
      "equipment": this.equipment,
      "link": this.link,
      "movement_nutrition": this.movementNutrition,
    };
    return map;
  }
}
