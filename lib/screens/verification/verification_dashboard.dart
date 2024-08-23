import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class VerificationDashboardPage extends StatefulWidget {
  const VerificationDashboardPage({super.key});

  @override
  State<VerificationDashboardPage> createState() => _VerificationDashboardPageState();
}

class _VerificationDashboardPageState extends State<VerificationDashboardPage> {
  File? _profileImage;
  File? _idImage;
  File? _diplomaImage;
  final ImagePicker _picker = ImagePicker();

  String verificationStatus = "Non vérifié";

  Future<void> _pickImage(ImageSource source, String imageType) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        switch (imageType) {
          case 'profile':
            _profileImage = File(image.path);
            break;
          case 'id':
            _idImage = File(image.path);
            break;
          case 'diploma':
            _diplomaImage = File(image.path);
            break;
        }
      });
    }
  }

  Widget _buildVerificationCard(String title, File? image, String imageType) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text(title),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _pickImage(ImageSource.gallery, imageType),
            ),
          ),
          image != null
              ? Image.file(image, height: 150)
              : Container(
            height: 150,
            color: Colors.grey.shade200,
            child: const Center(child: Text("Image non fournie")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification du Profil"),
      ),
      body: ListView(
        children: [
          _buildVerificationCard("Photo de Profil", _profileImage, 'profile'),
          _buildVerificationCard("Pièce d'identité", _idImage, 'id'),
          _buildVerificationCard("Diplôme", _diplomaImage, 'diploma'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Submit to Firestore logic
              },
              child: const Text("Soumettre pour vérification"),
            ),
          ),
          Text("Statut de vérification : $verificationStatus"),
        ],
      ),
    );
  }
}
