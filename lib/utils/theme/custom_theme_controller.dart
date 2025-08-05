import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_theme.dart';

class CustomThemeController extends GetxController {
  RxBool isDark = true.obs;
  CustomTheme myTheme = CustomTheme(color: Colors.blueGrey);
  ThemeData get customTheme => myTheme.customTheme;
  ThemeData get customThemeDark => myTheme.customThemeDark;
  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;

  void toogleTheme() {
    isDark.value = !isDark.value;
  }
}
