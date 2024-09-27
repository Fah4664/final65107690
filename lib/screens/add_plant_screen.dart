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
  
  String? _selectedComponent;
  String? _selectedLandUseType;
  String? _landUseTypeDescription;

  List<Map<String, dynamic>> _components = [];
  List<Map<String, dynamic>> _landUseTypes = [];

  @override
  void initState() {
    super.initState();
    _loadComponents();
    _loadLandUseTypes();
  }

  Future<void> _loadComponents() async {
    final db = DatabaseHelper();
    final components = await db.database.then((db) => db.query('plantComponent'));
    setState(() {
      _components = components;
    });
  }

  Future<void> _loadLandUseTypes() async {
    final db = DatabaseHelper();
    final landUseTypes = await db.database.then((db) => db.query('LandUseType'));
    setState(() {
      _landUseTypes = landUseTypes;
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
        landUseTypeName: _selectedLandUseType ?? '',
      ).then((_) {
        Navigator.pop(context, true); // กลับไปที่หน้าโฮมหลังจากบันทึกข้อมูล
        // อาจต้องเรียก setState() ในหน้าจอหลักเพื่ออัปเดตข้อมูลที่แสดง
      });
    }
  }

  void _onLandUseTypeSelected(String? value) {
    setState(() {
      _selectedLandUseType = value;
      // ค้นหาคำอธิบายจากฐานข้อมูล
      final selectedType = _landUseTypes.firstWhere(
          (type) => type['LandUseTypeName'] == value,
          orElse: () => {});
      _landUseTypeDescription = selectedType.isNotEmpty ? selectedType['LandUseTypeDescription'] : null;
    });
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
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Land Use Type'),
                items: _landUseTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['LandUseTypeName'],
                    child: Text(type['LandUseTypeName']),
                  );
                }).toList(),
                onChanged: _onLandUseTypeSelected,
                validator: (value) => value == null ? 'Please select a land use type' : null,
              ),
              if (_landUseTypeDescription != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Description: $_landUseTypeDescription'),
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
