class ChatUser {
  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.id,
    required this.isOnline,
    required this.lastActive,
    required this.pushToken,
    required this.email,
  });
  late  String image;
  late  String about;
  late  String name;
  late  String createdAt;
  late  String id;
  late  bool isOnline;
  late  String lastActive;
  late  String pushToken;
  late  String email;
  
  ChatUser.fromJson(Map<String, dynamic> json){
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    isOnline = json['is_online'] ?? '';
    lastActive = json['last_active'] ?? '';
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image'] = image;
    _data['about'] = about;
    _data['name'] = name;
    _data['created_at'] = createdAt;
    _data['id'] = id;
    _data['is_online'] = isOnline;
    _data['last_active'] = lastActive;
    _data['push_token'] = pushToken;
    _data['email'] = email;
    return _data;
  }
}



// class ChatUser{
//   ChatUser({
//     required this.estd,
//     required this.about,
//     required this.name,
//     required this.isOnline,
//     required this.trophy,
//     required this.email,
//   });
//   late final String estd;
//   late final String about;
//   late final String name;
//   late final bool isOnline;
//   late final String trophy;
//   late final String email;
  
//   ChatUser.fromJson(Map<String, dynamic> json){
//     estd = json['estd'] ?? '';
//     about = json['about'] ?? '';
//     name = json['name'] ?? '';
//     isOnline = json['is_online'] ?? '';
//     trophy = json['trophy'] ?? '';
//     email = json['email'] ?? '';
//   }

//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['estd'] = estd;
//     _data['about'] = about;
//     _data['name'] = name;
//     _data['is_online'] = isOnline;
//     _data['trophy'] = trophy;
//     _data['email'] = email;
//     return _data;
//   }
// }