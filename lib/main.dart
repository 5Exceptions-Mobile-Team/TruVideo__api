import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_upload_sample_app/splash_screen.dart';
import 'config/theme/app_theme.dart';
import 'core/services/local_database_service.dart';
import 'core/services/web_media_storage_service.dart';
import 'features/auth/models/credentials_model.dart';
import 'features/gallery/models/media_item_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize GetStorage for web persistence
    await GetStorage.init();

    // Initialize Hive - initFlutter works on web too with hive_flutter
    if (kIsWeb) {
      // For web, ensure proper initialization
      await Hive.initFlutter();
    } else {
      await Hive.initFlutter();
    }

    // Register adapters
    Hive.registerAdapter(CredentialsModelAdapter());
    Hive.registerAdapter(MediaItemModelAdapter());

    // Open databases
    await LocalDatabase().openLocalDB();
    await WebMediaStorageService().init();

    if (kDebugMode) {
      print('Storage initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing storage: $e');
    }
    // Continue anyway - app should still work
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Platform Demo',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

//  https://5Exceptions-Mobile-Team.github.io/TruVideo__api/
//  flutter run -d chrome --web-port=3000 --web-hostname=localhost
