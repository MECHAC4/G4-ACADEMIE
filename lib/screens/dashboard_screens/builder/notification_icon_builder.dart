import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsIcon extends StatelessWidget {
  final String userId;

  const NotificationsIcon({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('idTo', isEqualTo: userId)
          .where('estVue', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildIconWithBadge(0); // Affiche 0 si pas de données
        }
        int unreadCount = snapshot.data!.docs.length;
        return _buildIconWithBadge(unreadCount);
      },
    );
  }

  Widget _buildIconWithBadge(int count) {
    //count =5;
    return Padding(
      padding: const EdgeInsets.only(right: 18.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_active,  color: Colors.white, size: 25,), // L'icône de notification
          if (count > 0)
            Positioned(
              // Positionnement du badge en haut à droite
              right: -10,  // Ajustez pour positionner parfaitement
              top: -8,    // Ajustez pour positionner parfaitement
              child: Container(
                padding: const EdgeInsets.all(6),
                //margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.red, // Couleur du badge
                  shape: BoxShape.circle, // Forme du badge
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white, // Couleur du texte dans le badge
                    fontSize: 12, // Taille du texte
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
