import 'package:hive/hive.dart';

part 'credentials_model.g.dart';

@HiveType(typeId: 0)
class CredentialsModel {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? title;
  @HiveField(2)
  String? apiKey;
  @HiveField(3)
  String? secret;
  @HiveField(4)
  String? externalId;

  CredentialsModel({
    this.id,
    this.title,
    this.apiKey,
    this.secret,
    this.externalId,
  });

  CredentialsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    apiKey = json['api_key'];
    secret = json['secret_key'];
    externalId = json['external_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['api_key'] = this.apiKey;
    data['secret_key'] = this.secret;
    data['external_id'] = this.externalId;
    return data;
  }
}
