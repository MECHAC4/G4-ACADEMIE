import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../users.dart';

class UserProfilePage extends StatelessWidget {
  final AppUser user;

  const UserProfilePage({Key? key, required this.user}) : super(key: key);

  Future<Map<String, dynamic>?> getVerificationData() async {
    final doc = await FirebaseFirestore.instance
        .collection('verification')
        .doc(user.id)
        .get();

    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          return _buildUserInfoSection();
        },
      ),
    );
  }

  /*Widget _buildProfileWithVerification(
      BuildContext context, Map<String, dynamic> verificationData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image de profil
          //_buildProfileImage(context,verificationData['profileImage']),
          const SizedBox(height: 16),

          // Informations utilisateur
          _buildUserInfoSection(),
          //const Divider(height: 30, thickness: 2),

          // Vérification des documents
          /*const Text(
            'Informations de vérification',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),*/
          //const SizedBox(height: 16),
          //_buildVerificationDocuments(context,verificationData),
          //const SizedBox(height: 16),

          // Statut de vérification
          //_buildVerificationStatus(verificationData['status']),
          //if(verificationData['status'] == 'Non vérifié')
          /*ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => VerificationStepPage(
                  user: user,
                ),
              )); // Redirection vers la page de vérification
            },
            icon: const Icon(Icons.verified_user),
            label: const Text('Vérifier le profil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),*/
          const Text('\n'),
        ],
      ),
    );
  }*/

  /*Widget _buildProfileWithoutVerification(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Placeholder image de profil
          _buildProfileImage(context,null),
          const SizedBox(height: 16),

          // Informations utilisateur
          _buildUserInfoSection(),
          const Divider(height: 30, thickness: 2),

          // Message de non-vérification
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Cet utilisateur n\'a pas encore été vérifié.',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bouton pour la page de vérification
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => VerificationStepPage(
                  user: user,
                ),
              )); // Redirection vers la page de vérification
            },
            icon: const Icon(Icons.verified_user),
            label: const Text('Vérifier le profil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  /*Widget _buildProfileImage(BuildContext context,String? imageUrl) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          color: Colors.blueAccent,
        ),
        GestureDetector(
          onTap: () {
            if(imageUrl!=null){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ImageBuilder(url: imageUrl),));
            }
          },
          child: CircleAvatar(
            radius: 60,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            backgroundColor: Colors.white,
            child: imageUrl == null
                ? const Icon(Icons.person, color: Colors.blue, size: 50)
                : null,
          ),
        ),
      ],
    );
  }*/

  Widget _buildUserInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 30,color: Colors.orange,),
              Flexible(
                child: Text(
                  '    ${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green, size: 20,),
              Flexible(
                child: Text('    ${user.address}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.quiz, size: 20, color: Colors.brown,),
              Flexible(
                child: Text(
                  '    ${user.userType}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          if (user.userType == 'Enseignant' && user.subject != null)
            Row(
              children: [
                const Icon(Icons.subject, color: Colors.pinkAccent,size: 20,),
                Flexible(
                  child: Text(
                    '    ${user.subject!.join(", ")}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          if (user.userType == 'Elève')
            Row(
              children: [
                const Icon(Icons.class_sharp, color: Colors.cyan,size: 20,),
                Flexible(
                  child: Text(
                    '    ${user.studentClass ?? "Non spécifiée"}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /*Widget _buildVerificationDocuments(BuildContext context,Map<String, dynamic> verificationData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(child: _buildDocumentImage(context,verificationData['idImage'], 'Carte d\'identité')),
          if(user.userType == 'Enseignant')
          Flexible(child: _buildDocumentImage(context,verificationData['diplomaImage'], 'Diplôme')),
        ],
      ),
    );
  }*/

  /*Widget _buildDocumentImage(BuildContext context,String url, String label) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ImageBuilder(url: url),));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }*/

  /*Widget _buildVerificationStatus(String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Statut de vérification: '
              ),
              Flexible(
                child: Text(status,style: TextStyle(
                  color: status == 'Vérifié' ? Colors.green : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ), ),
              ),
            ],
          ),
          const SizedBox(height: 30,)
        ],
      ),
    );
  }*/
}
