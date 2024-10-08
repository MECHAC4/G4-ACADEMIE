import 'package:flutter/material.dart';

class ImageBuilder extends StatelessWidget {
  final String url;

  const ImageBuilder({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          }, icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Center(
        child: Image.network(
          url,
          errorBuilder: (context, error, stackTrace) {
            return const Text('Une erreur s\'est produite');
          },
          loadingBuilder: (context, child, loadingProgress) {
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
