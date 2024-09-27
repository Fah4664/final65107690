import 'package:flutter/material.dart';
import 'add_plant_screen.dart';
import '../helpers/database_helper.dart';
import 'plant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _plantsFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _plantsFuture = _dbHelper.getAllPlants(); // เรียกข้อมูลพืชทั้งหมดใน initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Information'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _plantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // แสดงวงล้อโหลด
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // แสดงข้อความข้อผิดพลาด
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No plants available')); // ถ้าไม่มีข้อมูล
          }

          // แสดงข้อมูลพืชใน ListView
          final plants = snapshot.data!;
          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: GestureDetector( // ใช้ GestureDetector เพื่อรองรับการแตะ
                    onTap: () {
                      // นำทางไปยังหน้าจอรายละเอียดพืช
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlantDetailScreen(plant: plant)),
                      ).then((value) {
                        if (value == true) {
                          setState(() {
                            _plantsFuture = _dbHelper.getAllPlants(); // รีเฟรชข้อมูลหลังจากกลับมาที่หน้าโฮม
                          });
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          plant['plantName'],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: plant['plantImage'] != null
                              ? ClipRect(
                                  child: Image.network(
                                    plant['plantImage'],
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Icon(Icons.nature),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // นำทางไปยังหน้าจอเพิ่มพรรณไม้
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPlantScreen()),
          ).then((value) {
            // เรียกใช้ setState() เพื่อรีเฟรชข้อมูลหลังจากกลับมาที่หน้าโฮม
            if (value == true) {
              // ถ้ามีการบันทึกข้อมูลใหม่
              setState(() {
                _plantsFuture = _dbHelper.getAllPlants(); // เรียกข้อมูลพืชใหม่
              });
            }
          });
        },
        child: Icon(Icons.add), // ไอคอนปุ่มเพิ่ม
      ),
    );
  }
}
