import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController ageController = TextEditingController();

  final TextEditingController heightController = TextEditingController();

  final TextEditingController weightController = TextEditingController();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadInformation();
  }

  // ==========================================
  // LOAD INFORMATION
  // ==========================================

  void _loadInformation() {
    try {
      final Box box = Hive.box('settingsBox');

      nameController.text = box.get('name', defaultValue: '').toString();

      ageController.text = box.get('age', defaultValue: '').toString();

      heightController.text = box.get('height', defaultValue: '').toString();

      weightController.text = box.get('weight', defaultValue: '').toString();
    } catch (e) {
      debugPrint('Error loading personal information: $e');
    }
  }

  // ==========================================
  // SAVE INFORMATION
  // ==========================================

  Future<void> _saveInformation() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final Box box = Hive.box('settingsBox');

      await box.put('name', nameController.text.trim());

      await box.put('age', ageController.text.trim());

      await box.put('height', heightController.text.trim());

      await box.put('weight', weightController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information saved successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save information.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      debugPrint('Error saving personal information: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();

    super.dispose();
  }

  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Information',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================
            // HEADER
            // ==================================
            const Text(
              'Your Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            Text(
              'Keep your fitness information updated.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 28),

            // ==================================
            // NAME
            // ==================================
            TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================
            // AGE
            // ==================================
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================
            // HEIGHT
            // ==================================
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                prefixIcon: Icon(Icons.height_rounded),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================
            // WEIGHT
            // ==================================
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================
            // SAVE BUTTON
            // ==================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveInformation,
                child: isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Information'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
