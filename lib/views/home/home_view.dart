
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Page')),
      body: const Center(child: Text('Welcome to the app!')),
    );
  }
}