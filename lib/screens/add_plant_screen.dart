import 'package:flutter/material.dart';
import '../helpers/database_helper.dart'; // เปลี่ยนเป็น path ที่ถูกต้องของ DatabaseHelper

class AddPlantScreen extends StatefulWidget {
  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plantNameController = TextEditingController();
  final TextEditingController _plantScientificController = TextEditingController();
  final TextEditingController _plantImageController = TextEditingController();
  final TextEditingController _landUseDescriptionController = TextEditingController();
  final TextEditingController _landUseTypeNameController = TextEditingController(); // เพิ่มสำหรับ LandUseTypeName
  final TextEditingController _landUseTypeDescriptionController = TextEditingController();
  
  String? _selectedComponent;
  

  List<Map<String, dynamic>> _components = [];

  @override
  void initState() {
    super.initState();
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    final db = DatabaseHelper();
    final components = await db.database.then((db) => db.query('plantComponent'));
    setState(() {
      _components = components;
    });
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      DatabaseHelper().insertLandUse(
        plantName: _plantNameController.text,
        plantScientific: _plantScientificController.text,
        landUseDescription: _landUseDescriptionController.text,
        plantImage: _plantImageController.text,
        componentName: _selectedComponent ?? '',
        landUseTypeName: _landUseTypeNameController.text,
        landUseTypeDescription: _landUseTypeDescriptionController.text, 
      ).then((_) {
        Navigator.pop(context, true); // กลับไปที่หน้าโฮมหลังจากบันทึกข้อมูล
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Plant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _plantNameController,
                decoration: InputDecoration(labelText: 'Plant Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a plant name' : null,
              ),
              TextFormField(
                controller: _plantScientificController,
                decoration: InputDecoration(labelText: 'Scientific Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a scientific name' : null,
              ),
              TextFormField(
                controller: _plantImageController,
                decoration: InputDecoration(labelText: 'Plant Image URL'),
                validator: (value) => value!.isEmpty ? 'Please enter a plant image URL' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Component'),
                items: _components.map((component) {
                  return DropdownMenuItem<String>(
                    value: component['componentName'],
                    child: Text(component['componentName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedComponent = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a component' : null,
              ),
              TextFormField(
                controller: _landUseTypeNameController,
                decoration: InputDecoration(labelText: 'Land Use Type Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a land use type name' : null,
              ),
              TextFormField(
                controller: _landUseTypeDescriptionController,
                decoration: InputDecoration(labelText: 'Land Use Type Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a land use type description' : null,
              ),
              TextFormField(
                controller: _landUseDescriptionController,
                decoration: InputDecoration(labelText: 'Land Use Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a land use description' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSubmit,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
