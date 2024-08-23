import 'package:flutter/material.dart';

class ImageBuilder extends StatelessWidget {
  final String url;
  const ImageBuilder({required this.url,super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(url),
      ),
    );
  }
}
