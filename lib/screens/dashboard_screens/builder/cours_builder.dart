import 'package:flutter/material.dart';
import 'package:g4_academie/theme/theme.dart';

class CoursBuilder extends StatefulWidget {
  const CoursBuilder({super.key});

  @override
  State<CoursBuilder> createState() => _CoursBuilderState();
}

class _CoursBuilderState extends State<CoursBuilder> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
      //itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: [
              const Color(0xFFE69558),
              const Color(0xFF9FCFF8),
              const Color(0xFF9A74C1),
              const Color(0xFFE6C88C),
              const Color(0xFFD3DDE6),
              const Color(0xFF556270),
              const Color(0xFF9DC0BA),
              Colors.orange
            ][index % 8]
                .withOpacity(0.1),
            border: Border.all(color: lightColorScheme.primary),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(child: Text("Matière ${index + 1}")),
        );
      },
    );
  }
}
