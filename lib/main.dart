import 'package:app_receitas/data/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'routes/app_router.dart';
import 'utils/configs/env.dart';
import 'utils/theme/custom_theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.init();

  await Supabase.initialize(
    url: Env.supabaseApiUrl,
    anonKey: Env.supabaseApiKey,
  );

  ServiceLocator().setup();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.put(CustomThemeController());

    return Obx(
      () => MaterialApp.router(
        title: 'Eu Amo Cozinhar',
        debugShowCheckedModeBanner: false,
        theme: theme.customTheme,
        darkTheme: theme.customThemeDark,
        themeMode: theme.isDark.value ? ThemeMode.dark : ThemeMode.light,
        routerConfig: AppRouter().router,
      ),
    );
  }
}
