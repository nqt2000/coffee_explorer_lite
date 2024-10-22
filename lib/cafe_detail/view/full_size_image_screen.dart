import 'dart:io';

import 'package:flutter/material.dart';

class FullSizeImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullSizeImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Image.file(
            File(imageUrl),
            fit: BoxFit.contain,
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
