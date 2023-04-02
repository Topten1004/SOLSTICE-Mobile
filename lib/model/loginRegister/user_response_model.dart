
class UserResponseModel {
  String status;
  String message;
  String token;


  UserDataModel data;
  UserResponseModel({this.status, this.message,this.token,this.data});

  UserResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    token = json['token'].toString();
    if (json['data'] != null) {
      data = UserDataModel.fromJson(json['data']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['token'] = this.token;
    if (this.data != null) {
      data['data'] = this.data;
    }
    return data;
  }
}

class UserDataModel {
  String id;
  String role;
  String name;
  String gender;
  String email;
  String status;
  String phone;
  String country_code;
  String address;
  String is_login;
  String image;

  UserDataModel(
      {this.id,this.role,this.name,this.gender,this.email,this.status,this.phone,this.country_code,
      this.address,this.is_login,this.image});

  UserDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    role = json['role'].toString();
    name = json['name'].toString();
    gender = json['gender'].toString();
    email = json['email'].toString();
    status = json['status'].toString();
    phone = json['phone'].toString();

    country_code = json['country_code'].toString();
    address = json['address'].toString();
    is_login = json['is_login'].toString();
    image = json['image'].toString();

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] =  this.role;
    data['name'] =  this.name;
    data['gender'] =  this.gender;
    data['email'] =  this.email;
    data['status'] =  this.status;
    data['phone'] =  this.phone;

    data['country_code'] =  this.country_code;
    data['address'] =  this.address;
    data['is_login'] =  this.is_login;
    data['image'] =  this.image;

    return data;
  }
}