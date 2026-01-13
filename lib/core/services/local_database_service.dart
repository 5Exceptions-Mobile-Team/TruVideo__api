import 'package:flutter/foundation.dart';
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
    try {
      credentialsBox = await Hive.openBox<CredentialsModel>(
        'credentials_box',
        compactionStrategy: (entries, deletedEntries) => deletedEntries > 10,
      );
      
      // Ensure data is persisted on web
      if (kIsWeb && credentialsBox != null) {
        await credentialsBox!.flush();
      }
      
      if (kDebugMode) {
        print('LocalDatabase opened successfully. Items: ${credentialsBox?.length ?? 0}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opening LocalDatabase: $e');
      }
      rethrow;
    }
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
