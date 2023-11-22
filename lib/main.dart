import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hot_deal_generation/firebase_options.dart';
import 'package:hot_deal_generation/screen/screen_home.dart';
import 'package:hot_deal_generation/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: Builder(
          builder: (BuildContext context) {
            ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

            // Define the callback function
            onChangedTheme() {
              // You can add logic here to handle theme change
              print("Theme Changed!");
            }

            return MyApp(onChangedTheme: onChangedTheme);
          },
        ),
      ),
    );
  } catch (e) {
    print("에러 : $e");
  }
}

class MyApp extends StatelessWidget {
  final VoidCallback onChangedTheme; // Callback function

  const MyApp({super.key, required this.onChangedTheme});

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<ThemeProvider>(context),
      child: ValueListenableBuilder(
        valueListenable: themeNotifier,
        builder: (context, value, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: '핫딜시대',
            darkTheme: ThemeData.dark(),
            themeMode: value,
            home: HomeScreen(onThemeChanged: onChangedTheme),
          );
        },
      ),
    );
  }
}
