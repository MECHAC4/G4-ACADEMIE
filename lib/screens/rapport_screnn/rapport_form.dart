import 'package:flutter/material.dart';
import 'package:g4_academie/cours.dart';
import 'package:g4_academie/users.dart';

import 'rapport_view.dart';

class ReportFormPage extends StatefulWidget {
  final Cours course;
  final AppUser appUser;

  const ReportFormPage({super.key, required this.course, required this.appUser});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKeyList = List.generate(
    5,
    (index) => GlobalKey<FormState>(),
  );

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _themeController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _participationController =
      TextEditingController();
  final TextEditingController _difficultiesController = TextEditingController();
  final TextEditingController _improvementController = TextEditingController();
  final TextEditingController _nextCourseController = TextEditingController();
  final TextEditingController _homeworkController = TextEditingController();
  final TextEditingController _parentNoteController = TextEditingController();

  int _currentStep = 0;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dateController.text = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    _studentNameController.text = widget.course.studentFullName;
    _subjectController.text = widget.course.subject;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: Colors.blue,
        title: const Text(
          'Rapport de cours',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Stepper(
            currentStep: _currentStep,
            onStepTapped: (step) => setState(() => _currentStep = step),
            onStepContinue: _currentStep < 4
                ? () {
                    if (_formKeyList[_currentStep].currentState!.validate()) {
                      setState(() {
                        _currentStep += 1;
                      });
                    }
                  }
                : _submitForm,
            // Call the function to handle form submission
            onStepCancel: _currentStep > 0
                ? () {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                : null,
            steps: _buildSteps(),
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child:
                        Text(_currentStep >= 4 ? 'Voir le rapport' : 'Suivant'),
                  ),
                  const SizedBox(width: 8),
                  if (_currentStep != 0)
                    ElevatedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Précédent'),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Informations de base'),
        content: Form(
          key: _formKeyList[0],
          child: Column(
            children: [
              _buildTextField(_dateController, 'Date du cours'),
              _buildTextField(_studentNameController, 'Nom de l\'élève'),
              _buildTextField(_levelController, 'Niveau de l\'élève'),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Détails du cours'),
        content: Form(
          key: _formKeyList[1],
          child: Column(
            children: [
              _buildTextField(_subjectController, 'Matière'),
              _buildTextField(_themeController, 'Thème du cours'),
              _buildTextField(_contentController, 'Contenu du cours'),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Participation & Difficultés'),
        content: Form(
          key: _formKeyList[2],
          child: Column(
            children: [
              _buildTextField(
                  _participationController, 'Participation de l\'élève'),
              _buildTextField(
                  _difficultiesController, 'Difficultés rencontrées'),
            ],
          ),
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Progrès & Prochain cours'),
        content: Form(
          key: _formKeyList[3],
          child: Column(
            children: [
              _buildTextField(_improvementController, 'Progrès observés'),
              _buildTextField(
                  _nextCourseController, 'Suggestions pour le prochain cours'),
            ],
          ),
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Devoirs & Remarques'),
        content: Form(
          key: _formKeyList[4],
          child: Column(
            children: [
              _buildTextField(_homeworkController, 'Devoirs donnés'),
              _buildTextField(
                  _parentNoteController, 'Remarques pour les parents'),
            ],
          ),
        ),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  bool verifyForm() {
    bool answer = true;
    for (int i = 0; i < _formKeyList.length; i++) {
      final formKey = _formKeyList[i];
      if (!formKey.currentState!.validate()) {
        return false;
      }
    }
    return answer;
  }

  void _submitForm() {
    if (verifyForm()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewPage(
            rapport: null,
            canSend: true,
            canValid: false,
            date: _dateController.text,
            studentName: _studentNameController.text,
            level: _levelController.text,
            subject: _subjectController.text,
            theme: _themeController.text,
            content: _contentController.text,
            participation: _participationController.text,
            difficulties: _difficultiesController.text,
            improvement: _improvementController.text,
            nextCourse: _nextCourseController.text,
            homework: _homeworkController.text,
            parentNote: _parentNoteController.text, course: widget.course, appUser: widget.appUser,
          ),
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        maxLines: null,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez remplir ce champ.\n Remplissez le champ par "RAS" s\'il n\'y a rien à signaler';
          }
          return null;
        },
      ),
    );
  }
}
