import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Politique de Confidentialité',
          style: TextStyle(color: Colors.white),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Politique de Confidentialité de G4 ACADEMIE',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bienvenue sur G4 ACADEMIE ! Cette politique de confidentialité décrit comment nous collectons, utilisons et protégeons vos informations personnelles lorsque vous utilisez notre plateforme. En accédant à notre application et en utilisant nos services, vous acceptez les termes décrits dans cette politique.',
              ),
              const SizedBox(height: 16),
              buildSectionTitle('1. Informations Que Nous Collectons'),
              buildSectionContent(
                'Informations Personnelles',
                'Nous collectons les informations personnelles suivantes : Nom, Adresse e-mail, Numéro de téléphone, Adresse postale, Informations de paiement, Nom de l\'élève et détails éducatifs.',
              ),
              buildSectionContent(
                'Informations Non-Personnelles',
                'Nous pouvons également collecter des informations non personnelles telles que : Type et version du navigateur, Système d\'exploitation, Pages visitées sur l\'application, Date et heure de la visite, Adresse IP.',
              ),
              const SizedBox(height: 16),
              buildSectionTitle('2. Comment Nous Utilisons Vos Informations'),
              buildSectionContent(
                '',
                'Nous utilisons les informations collectées pour : Fournir et améliorer nos services éducatifs, Traiter les paiements et gérer la facturation, Communiquer avec vous concernant nos services, mises à jour et promotions, Personnaliser votre expérience sur notre plateforme, Analyser l\'utilisation de l\'application pour améliorer nos services, Respecter les obligations légales.',
              ),
              const SizedBox(height: 16),
              buildSectionTitle('3. Partage de Vos Informations'),
              buildSectionContent(
                '',
                'Vos informations personnelles ne seront pas vendues, échangées, ou louées à des tiers. Cependant, elles peuvent être partagées dans certaines situations comme avec des prestataires de services, lorsque requis par la loi, ou pour protéger nos droits et la sécurité de nos utilisateurs.',
              ),
              const SizedBox(height: 16),
              buildSectionTitle('4. Sécurité des Données'),
              buildSectionContent(
                '',
                'Nous appliquons des mesures de sécurité telles que l\'utilisation de logiciels de serveur sécurisé (SSL) pour crypter les informations sensibles et la mise à jour régulière des pratiques de sécurité pour assurer la protection des données.',
              ),
              const SizedBox(height: 16),
              buildSectionTitle('5. Liens Tiers'),
              buildSectionContent(
                '',
                'Notre application peut contenir des liens vers des sites tiers. Nous ne sommes pas responsables de leur politique de confidentialité ou de leur contenu.',
              ),
              const SizedBox(height: 16),
              buildSectionTitle('6. Confidentialité des Enfants'),
              buildSectionContent(
                '',
                'Nous ne collectons pas intentionnellement d\'informations personnelles auprès des enfants de moins de 13 ans sans consentement parental.',
              ),
              const SizedBox(height: 16),
              buildSectionTitle('7. Vos Droits'),
              buildSectionContent(
                '',
                'Vous avez le droit d\'accéder aux informations personnelles que nous détenons, de demander leur correction ou suppression, de vous opposer au traitement de vos données, et de retirer votre consentement à tout moment.',
              ),
              const SizedBox(height: 16),
              buildSectionTitle(
                  '8. Modifications de Cette Politique de Confidentialité'),
              buildSectionContent(
                '',
                'Nous pouvons mettre à jour cette politique de temps à autre. Toute modification sera publiée sur cette page. Nous vous encourageons à la consulter régulièrement.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget buildSectionContent(String subtitle, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 8),
        Text(content),
      ],
    );
  }
}
