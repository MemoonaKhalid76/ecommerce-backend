import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';

import 'services/network_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NetworkService().initialize();
  }

  @override
  void dispose() {
    NetworkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// 🛒 CART PROVIDER (already working)
        ChangeNotifierProvider(create: (_) => CartProvider()),

        /// 🔐 AUTH PROVIDER (OTP login)
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadAuth()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: NetworkService().scaffoldMessengerKey, // 🔑 LINKED!
        debugShowCheckedModeBanner: false,
        title: 'Fareed Book Centre',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins', // If available, otherwise default
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
