import 'package:hive/hive.dart';

class UserSettings extends HiveObject {
  String? companyName;
  String? lang;
  String? type;
  String? userName;
  String? userAuthToken;
  String? email;
  String? url;
  String? database;

  UserSettings({
    this.companyName,
    this.lang,
    this.type,
    this.userName,
    this.userAuthToken,
    this.email,
    this.url,
    this.database,
  });

  void clear() {
    companyName = null;
    lang = null;
    type = null;
    userName = null;
    userAuthToken = null;
    email = null;
    url = null;
    database = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'lang': lang,
      'type': type,
      'userName': userName,
      'userAuthToken': userAuthToken,
      'email': email,
      'url': url,
      'database': database,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      companyName: json['companyName'],
      lang: json['lang'],
      type: json['type'],
      userName: json['userName'],
      userAuthToken: json['userAuthToken'],
      email: json['email'],
      url: json['url'],
      database: json['database'],
    );
  }
}

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 0;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      companyName: fields[0] as String?,
      lang: fields[1] as String?,
      type: fields[2] as String?,
      userName: fields[3] as String?,
      userAuthToken: fields[4] as String?,
      email: fields[5] as String?,
      url: fields[6] as String?,
      database: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.companyName)
      ..writeByte(1)
      ..write(obj.lang)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.userName)
      ..writeByte(4)
      ..write(obj.userAuthToken)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.url)
      ..writeByte(7)
      ..write(obj.database);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
