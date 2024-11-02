import 'package:flutter/material.dart';

class ZigZagMarquee extends StatefulWidget {
  final String text;

  const ZigZagMarquee({super.key, required this.text});

  @override
  State<ZigZagMarquee> createState() => _ZigZagMarqueeState();
  //_ZigZagMarqueeState createState() => _ZigZagMarqueeState();
}

class _ZigZagMarqueeState extends State<ZigZagMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // Initialise l'AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Durée pour chaque aller-retour
    )..repeat(reverse: true); // Répète l'animation en sens inverse pour un effet va-et-vient

    // Crée un Tween pour déplacer le texte de gauche à droite et inversement
    _animation = Tween<Offset>(
      begin: const Offset(-0.5, 0.0), // Position de départ à gauche
      end: const Offset(0.5, 0.0),    // Position de fin à droite
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Douceur de l’animation
    ));
  }

  @override
  void dispose() {
    _controller.dispose(); // Arrête le contrôleur lorsque le widget est supprimé
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child:  Text(
        widget.text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0, // Ajustez la taille selon vos préférences
          color: Colors.black,
        ),
      ),
    );
  }
}
