class GameUser{
  final String name;
  final String email;
  String ? id;
  String? password;

  GameUser({required this.name,required this.email,this.password,this.id});
  GameUser.fromJson(Map<String,dynamic> json):id=json['id'],name=json['name'],email=json['email'];
  toJson()=>{'name':name,'email':email,'id':id??""};
}
