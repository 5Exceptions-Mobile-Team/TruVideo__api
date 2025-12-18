import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_upload_sample_app/splash_screen.dart';
import 'config/theme/app_theme.dart';
import 'core/services/local_database_service.dart';
import 'features/auth/models/credentials_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Hive.initFlutter();

  Hive.registerAdapter(CredentialsModelAdapter());
  await LocalDatabase().openLocalDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Media Upload Sample App',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

/*
RDz1WWm9lO
YIF88kiQcx
 */
