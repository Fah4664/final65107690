import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'edit_plant_screen.dart';

class PlantDetailScreen extends StatelessWidget {
  final Map<String, dynamic> plant;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  PlantDetailScreen({required this.plant});
  // ฟังก์ชันลบข้อมูลพืช

  void _deletePlant(BuildContext context) async {
    // ลบพืชจากฐานข้อมูล
    await _dbHelper.deletePlant(plant['plantID']); // ใช้ plantID ในการลบ
    
    // ตรวจสอบว่าข้อมูลถูกลบจริง
    final remainingPlants = await _dbHelper.getAllPlants();
    print("Remaining Plants: $remainingPlants");

    Navigator.pop(context, true); // นำทางกลับและส่งค่า true เพื่อบอกว่ามีการลบ
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dbHelper.getPlantDetails(plant['plantID']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('ไม่พบข้อมูล.'));
        }

        var details = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(plant['plantName']),
            actions: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deletePlant(context),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                plant['plantImage'] != null
                    ? Image.network(plant['plantImage'])
                    : Icon(Icons.nature, size: 100),
                SizedBox(height: 20),
                Text('Plant Name: ${details['plantName']}', style: TextStyle(fontSize: 20)),
                Text('Scientific Name: ${details['plantScientific']}', style: TextStyle(fontSize: 20)),
                Text('Component Name: ${details['componentName'] ?? 'N/A'}', style: TextStyle(fontSize: 20)),
                Text('Land Use Type Name: ${details['landUseTypeName']}', style: TextStyle(fontSize: 20)),
                Text('Land Use Type Description: ${details['landUseTypeDescription']}', style: TextStyle(fontSize: 20)),
                Text('Land Use Description: ${details['landUseDescription']}', style: TextStyle(fontSize: 20)),
                SizedBox(height: 20),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewEditPlantScreen(plantData: plant),
                      ),
                    );
                  },
                  child: Text('แก้ไข'),
                ),
                ElevatedButton(
                  onPressed: () => _deletePlant(context), // เรียกใช้ฟังก์ชันลบ
                  child: Text('ลบ'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
