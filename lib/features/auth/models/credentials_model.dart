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
  @HiveField(5)
  String? credentialType;

  CredentialsModel({
    this.id,
    this.title,
    this.apiKey,
    this.secret,
    this.externalId,
    this.credentialType,
  });

  CredentialsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    apiKey = json['api_key'];
    secret = json['secret_key'];
    externalId = json['external_id'];
    credentialType = json['credential_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['api_key'] = apiKey;
    data['secret_key'] = secret;
    data['external_id'] = externalId;
    data['credential_type'] = credentialType;
    return data;
  }
}
