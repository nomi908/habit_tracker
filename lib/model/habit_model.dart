class HabitModel{
  int? id;
  String title;
  bool isCompleted;

  HabitModel({this.id, required this.title, this.isCompleted = false});


  //convert into json

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted ? 1 : 0,
  };

  //convert form json

  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'] == 1,
  );
}