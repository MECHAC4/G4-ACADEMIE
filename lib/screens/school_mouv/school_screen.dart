import "package:flutter/material.dart";


class CoursPage extends StatelessWidget {
  final List<Map<String, dynamic>> levels = [
    {'title': 'Primaire', 'grades': ['CP', 'CE1', 'CE2', 'CM1', 'CM2']},
    {'title': 'Collège', 'grades': ['6ème', '5ème', '4ème', '3ème']},
    {'title': 'Lycée', 'grades': ['Seconde', 'Première', 'Terminale']},
  ];

   CoursPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des cours', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: levels.length,
        itemBuilder: (context, index) {
          return CourseLevelCard(level: levels[index]);
        },
      ),
    );
  }
}

class CourseLevelCard extends StatelessWidget {
  final Map<String, dynamic> level;

  const CourseLevelCard({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              level['title'],
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            ...level['grades'].map<Widget>((grade) {
              return Card(
                color: Colors.white54,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  minTileHeight: 80,
                  title: Text(grade, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),),
                  trailing:  IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: (){},),
                  ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}



class HomePage2 extends StatelessWidget {
  void _openSubjectsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SubjectsDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélection des Matières'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _openSubjectsDialog(context),
          child: Text('Choisir une matière'),
        ),
      ),
    );
  }
}

class SubjectsDialog extends StatefulWidget {
  @override
  _SubjectsDialogState createState() => _SubjectsDialogState();
}

class _SubjectsDialogState extends State<SubjectsDialog> {
  final Map<String, List<String>> subjects = {
    'Sciences': ['Maths', 'PCT', 'SVT'],
    'Sciences humaines': ['Histoire-géo', 'Philosophie'],
    'Langues': ['Allemand', 'Anglais', 'Espagnol', 'Français'],
    'Primaire': ['Aide aux devoirs'],
    //'Sports': ['Arts Martiaux', 'Athlétisme', 'Cyclisme', 'Danse', 'Fitness', 'Musculation', 'Yoga'],
    //'Musique': ['Guitare', 'Piano', 'Violon'],
    'Autres': ['Informatique'],
  };

  String searchQuery = '';
  List<String> filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredSubjects();
  }

  void _updateFilteredSubjects() {
    setState(() {
      filteredSubjects = [];
      subjects.forEach((category, items) {
        filteredSubjects.add(category);
        filteredSubjects.addAll(
          items.where((subject) => subject.toLowerCase().contains(searchQuery.toLowerCase())),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choisissez une matière'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                  _updateFilteredSubjects();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredSubjects.length,
                itemBuilder: (context, index) {
                  String item = filteredSubjects[index];
                  bool isCategory = subjects.containsKey(item);

                  if (isCategory) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        item,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                    );
                  }
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      Navigator.of(context).pop(item); // Retourne la matière sélectionnée
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Ferme la boîte de dialogue sans sélection
          },
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
