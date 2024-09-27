import 'package:flutter/material.dart';
import '../helpers/database_helper.dart'; // นำเข้า DatabaseHelper

class PlantDetailScreen extends StatelessWidget {
  final Map<String, dynamic> plant;
  final DatabaseHelper _dbHelper = DatabaseHelper(); // สร้างอินสแตนซ์ DatabaseHelper

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
    return Scaffold(
      appBar: AppBar(
        title: Text(plant['plantName']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            plant['plantImage'] != null
                ? Image.network(plant['plantImage'])
                : Icon(Icons.nature, size: 100),
            SizedBox(height: 20),
            Text(
              plant['plantScientific'] ?? 'Scientific name not available',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _deletePlant(context), // เรียกใช้ฟังก์ชันลบเมื่อคลิก
              child: Text('Delete Plant'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 230, 114, 106)), // แก้ไขที่นี่
            ),
          ],
        ),
      ),
    );
  }
}
