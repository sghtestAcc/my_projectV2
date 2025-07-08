import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/models/medications.dart';
import 'package:my_project/repos/user_repo.dart';

class EditMedicationsPage extends StatefulWidget {
  final Medication medication;
  final String uid;

  const EditMedicationsPage({Key? key, required this.medication, required this.uid}) : super(key: key);

  @override
  State<EditMedicationsPage> createState() => _EditMedicationsPageState();
}

class _EditMedicationsPageState extends State<EditMedicationsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController labelController;
  late TextEditingController quantityController;
  late TextEditingController dosageController;
  late TextEditingController instructionsController;
  late TextEditingController detailsController;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.medication.labels);
    quantityController = TextEditingController(text: widget.medication.quantity ?? '');
    dosageController = TextEditingController(text: widget.medication.dosage ?? '');
    instructionsController = TextEditingController(text: widget.medication.instructions ?? '');
    detailsController = TextEditingController(text: widget.medication.details ?? '');
  }

  @override
  void dispose() {
    labelController.dispose();
    quantityController.dispose();
    dosageController.dispose();
    instructionsController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await UserRepository.instance.firestore
          .collection("users")
          .doc(widget.uid)
          .collection('medications')
          .doc(widget.medication.id)
          .update({
        "Labels": labelController.text.trim(),
        "Quantity": quantityController.text.trim(),
        "Dosage": dosageController.text.trim(),
        "Instructions": instructionsController.text.trim(),
        "Details": detailsController.text.trim(),
      });

      Get.snackbar(
        "Success",
        "Medication updated successfully.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF35365D).withOpacity(0.5),
        colorText: Color(0xFFF6F3E7),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update medication.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: labelController,
                decoration: InputDecoration(labelText: 'Medication Label'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: dosageController,
                decoration: InputDecoration(labelText: 'Dosage'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: instructionsController,
                decoration: InputDecoration(labelText: 'Instructions'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: detailsController,
                decoration: InputDecoration(labelText: 'Details'),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0CE25C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}