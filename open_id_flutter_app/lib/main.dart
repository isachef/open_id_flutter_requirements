import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'blocs/auth_bloc.dart';
import 'config/router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appAuth = FlutterAppAuth();
    final storage = const FlutterSecureStorage();

    return BlocProvider(
      create:
          (context) =>
              AuthBloc(appAuth: appAuth, storage: storage)..checkAuthStatus(),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'OpenID Connect Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4169E1),
                brightness: Brightness.light,
                primary: const Color(0xFF4169E1),
                secondary: const Color(0xFF03A9F4),
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.robotoTextTheme(
                Theme.of(context).textTheme,
              ),
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            routerConfig: createRouter(context),
          );
        },
      ),
    );
  }
}
