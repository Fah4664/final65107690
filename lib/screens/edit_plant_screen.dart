import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class ViewEditPlantScreen extends StatefulWidget {
  final Map<String, dynamic> plantData;

  ViewEditPlantScreen({required this.plantData});

  @override
  _ViewEditPlantScreenState createState() => _ViewEditPlantScreenState();
}

class _ViewEditPlantScreenState extends State<ViewEditPlantScreen> {
  late TextEditingController _plantNameController;
  late TextEditingController _scientificNameController;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _plantNameController = TextEditingController(text: widget.plantData['plantName']);
    _scientificNameController = TextEditingController(text: widget.plantData['plantScientific']);
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _scientificNameController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    // ใช้ plantID เพื่อบันทึกการเปลี่ยนแปลง
    await _dbHelper.updatePlant(widget.plantData['plantID'], {
      'plantName': _plantNameController.text,
      'plantScientific': _scientificNameController.text,
    });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Plant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _plantNameController,
              decoration: InputDecoration(labelText: 'Plant Name'),
            ),
            TextField(
              controller: _scientificNameController,
              decoration: InputDecoration(labelText: 'Scientific Name'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveChanges, // เรียกใช้ฟังก์ชันบันทึกการเปลี่ยนแปลง
        child: Icon(Icons.save),
      ),
    );
  }
}
