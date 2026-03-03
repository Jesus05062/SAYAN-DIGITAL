import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sayan_digital/providers/auth_provider.dart';
import 'package:sayan_digital/providers/current_account_provider.dart';
import 'package:sayan_digital/providers/register_provider.dart';
import 'package:sayan_digital/screens/acc_reg.dart';
import 'package:sayan_digital/screens/auth/login_screen.dart';
import 'package:sayan_digital/screens/auth/register_screen.dart';
import 'package:sayan_digital/screens/codigos_screen.dart';
import 'package:sayan_digital/screens/home_screen.dart';
import 'package:sayan_digital/screens/principal_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => RegisterProvider(), lazy: false),
        ChangeNotifierProvider(
          create: (_) => CurrentAccountProvider(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sayan Digital',
        theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
        initialRoute: 'inicio',
        routes: {
          'inicio': (_) => const AccReg(),
          'acceder': (_) => const LoginScreen(),
          'registro': (_) => const RegisterScreen(),
          'codigos': (_) => const CodigosScreen(),
          //'home': (_) => const HomeScreen(),
          'principal': (_) => const PrincipalScreen(),
        },
      ),
    );
  }
}
