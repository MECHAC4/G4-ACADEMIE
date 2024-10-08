import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'À Propos de Nous',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Qui sommes-nous ?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Bienvenue à G4 ACADEMIE ! Je suis Gildas Eucher, et laissez-moi vous raconter notre histoire.\n\n"
                    "Cela fait déjà plus de quinze ans que je jongle entre les tableaux noirs et les cahiers d’exercices. Pendant mon parcours, j’ai fait une découverte surprenante : les parents veulent désespérément des répétiteurs pour leurs enfants, mais leurs portefeuilles crient souvent à l’aide ! Constatant cette réalité, j’ai décidé qu’il fallait faire quelque chose.\n\n"
                    "C’est ainsi qu’est née G4 ACADEMIE. Mon objectif était simple : offrir des cours de soutien scolaire de qualité, accessibles à tous, sans faire pleurer les comptes bancaires des parents.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              Text(
                "Chez G4 Académie, nous sommes passionnés par l’éducation et nous engageons à offrir un tutorat de haute qualité. Notre approche personnalisée et nos méthodes innovantes permettent à chaque élève d’atteindre ses objectifs académiques et de réussir.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 20),


              const SizedBox(height: 20),
              const Text(
                'Notre Vision',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "\"Il est impossible à un homme d'apprendre ce qu'il pense déjà savoir.\"\n\n"
                "Notre vision chez G4 Académie est de devenir un leader reconnu dans le domaine du tutorat en offrant une éducation de haute qualité adaptée aux besoins individuels de chaque élève.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nos Valeurs',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Qualité\n"
                "Nous nous engageons à fournir un enseignement de haute qualité pour maximiser la réussite des élèves.\n\n"
                "Accessibilité\n"
                "Nous offrons des services accessibles à tous, garantissant que chaque étudiant peut bénéficier de notre soutien.\n\n"
                "Environnement Stimulant\n"
                "Nous créons un environnement d'apprentissage dynamique et motivant pour encourager la curiosité et la réussite.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 20),
              const Text(
                'Apprenez des leaders de l\'industrie',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Apprenez des leaders de l'industrie et bénéficiez de leur expertise pour exceller dans votre domaine.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 20),
              const Text(
                'Apprenez à votre propre rythme',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Apprenez à votre propre rythme avec des cours flexibles adaptés à vos besoins et horaires.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 20),
              const Text(
                'Certificat Professionnel',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Obtenez un certificat professionnel reconnu pour valider vos compétences et booster votre carrière.",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
