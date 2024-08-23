import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../users.dart';



class VerificationStepPage extends StatefulWidget {
  final AppUser? user;
  final String? source;
  const VerificationStepPage({super.key, this.user, this.source});

  @override
  State<VerificationStepPage> createState() => _VerificationStepPageState();
}

class _VerificationStepPageState extends State<VerificationStepPage> {
  int currentStep = 0;
  File? _profileImage;
  File? _idImage;
  File? _diplomaImage;
  final ImagePicker _picker = ImagePicker();

  // Firebase references
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to pick an image
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

  // Function to upload image to Firebase Storage
  Future<String> _uploadImage(File image, String folderName) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = _storage.ref().child('$folderName/$fileName');
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Function to save verification data
  Future<void> _submitVerification(AppUser user) async {
    if (_profileImage != null && _idImage != null &&
        (user.userType == 'teacher' ? _diplomaImage != null : true)) {
      String profileUrl = await _uploadImage(_profileImage!, 'profile');
      String idUrl = await _uploadImage(_idImage!, 'id');
      String diplomaUrl = user.userType == 'teacher' ?
      await _uploadImage(_diplomaImage!, 'diploma') : '';

      await _firestore.collection('verification').doc(user.id).set({
        'profileImage': profileUrl,
        'idImage': idUrl,
        'diplomaImage': user.userType == 'teacher' ? diplomaUrl : '',
        'status': 'En cours de vérification',
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vérification soumise avec succès.'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez fournir toutes les images.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
        title: const Text("Photo de Profil"),
        content: Column(
          children: [
            _profileImage != null
                ? CircleAvatar(
              backgroundImage: FileImage(_profileImage!),
              radius: 50,
            )
                : CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, size: 50),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery, 'profile'),
              child: const Text("Ajouter Photo de Profil"),
            ),
          ],
        ),
        isActive: currentStep >= 0,
      ),
      Step(
        title: const Text("Pièce d'identité"),
        content: Column(
          children: [
            _idImage != null
                ? Image.file(_idImage!, height: 150)
                : const Placeholder(fallbackHeight: 150),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery, 'id'),
              child: const Text("Télécharger Carte d'Identité"),
            ),
          ],
        ),
        isActive: currentStep >= 1,
      ),
    ];

    // Add diploma step only if the user is a teacher
    if (widget.user?.userType == 'teacher') {
      steps.add(
        Step(
          title: const Text("Diplôme"),
          content: Column(
            children: [
              _diplomaImage != null
                  ? Image.file(_diplomaImage!, height: 150)
                  : const Placeholder(fallbackHeight: 150),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery, 'diploma'),
                child: const Text("Télécharger Diplôme"),
              ),
            ],
          ),
          isActive: currentStep >= 2,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification de Compte"),
      ),
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < steps.length - 1) {
            setState(() {
              currentStep++;
            });
          } else {
            _submitVerification(widget.user!);
            Navigator.of(context).pop();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() {
              currentStep--;
            });
          }
        },
        steps: steps,
      ),
    );
  }
}
