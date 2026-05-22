class MessModel {
  String? id;
  String? name;
  String? description;
  String? address;

  MessModel({this.id, this.name, this.description, this.address});

  MessModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['address'] = this.address;
    return data;
  }
}
