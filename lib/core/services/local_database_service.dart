import 'package:hive/hive.dart';
import 'package:media_upload_sample_app/features/auth/models/credentials_model.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;

  Box<CredentialsModel>? credentialsBox;

  LocalDatabase._internal() {
    // openLocalDB();
  }

  Future<void> openLocalDB() async {
    credentialsBox = await Hive.openBox(
      'credentials_box',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 10,
    );
  }

  Future<void> closeLocalDb() async {
    await credentialsBox?.close();
  }

  Future<void> saveNewCredentials(CredentialsModel credentials) async {
    await credentialsBox?.put(credentials.id, credentials);
  }

  List<CredentialsModel> getCredentials() {
    return credentialsBox?.values.toList() ?? [];
  }

  Future<void> updateCredentials(CredentialsModel credentials) async {
    await credentialsBox?.put(credentials.id, credentials);
  }

  Future<void> deleteCredentials(String id) async {
    await credentialsBox?.delete(id);
  }
}
