import 'package:flutter/material.dart';

class IconWithBadge extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final double iconSize;

  const IconWithBadge({super.key,
    required this.icon,
    required this.badgeCount,
    this.iconSize = 40.0, // Taille de l'icône
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          icon,
          size: iconSize, // Taille de l'icône
        ),
        if (badgeCount > 0)
          Positioned(
            right: -8,  // Ajustez pour mieux positionner
            top: -8,    // Ajustez pour mieux positionner
            child: Container(
              padding: const EdgeInsets.all(6), // Augmentez légèrement le padding
              decoration: const BoxDecoration(
                color: Colors.red, // Couleur du badge
                shape: BoxShape.circle, // Forme du badge
              ),
              child: Text(
                iconSize ==26 ?'': badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white, // Couleur du texte dans le badge
                  fontSize: 12, // Taille du texte
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
