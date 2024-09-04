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
    return Stack(
      children: [
        const Icon(Icons.notifications,  color: Colors.white,), // L'icône de notification
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.red.shade400, // Couleur de fond du badge
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white, // Couleur du texte
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ],
    );
  }
}
