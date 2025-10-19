import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_banking_flutter/screens/auth/login_page.dart';

void main() {
  runApp(const DeltaPharmacyApp());
}

class DeltaPharmacyApp extends StatelessWidget {
  const DeltaPharmacyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delta Pharmacy Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}