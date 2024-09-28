import 'package:flutter/material.dart';
import 'add_plant_screen.dart';
import '../helpers/database_helper.dart';
import 'plant_detail_screen.dart';
import 'search_plant_screen.dart';
import 'view_plant_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _plantsFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _selectedIndex = 0; // ตัวแปรเก็บ index ของ Bottom Navigation Bar

  @override
  void initState() {
    super.initState();
    _plantsFuture = _dbHelper.getAllPlants(); // เรียกข้อมูลพืชทั้งหมดใน initState
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // อัปเดต index เมื่อผู้ใช้กดปุ่มใน Bottom Navigation Bar
    });

    // ตรวจสอบว่ากดปุ่มไหน
    if (_selectedIndex == 0) {
      // พาไปหน้า AddPlantScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddPlantScreen()),
      ).then((value) {
        if (value == true) {
          setState(() {
            _plantsFuture = _dbHelper.getAllPlants(); // รีเฟรชข้อมูลหลังจากกลับมาที่หน้าโฮม
          });
        }
      });
    } else if (_selectedIndex == 1) {
      // พาไปหน้า ViewScreen 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewScreen()),
      );
    } else if (_selectedIndex == 2) {
      // พาไปหน้า SearchPlantScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchPlantScreen()),
      );
    }
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No plants available'));
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
                  child: GestureDetector(
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
                          '${plant['plantName']} : ${plant['plantScientific']}',
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
      
      // เพิ่ม BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add), // ไอคอนสำหรับเพิ่มพรรณไม้
            label: 'Add Plant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit), // ไอคอนสำหรับดูพรรณไม้ทั้งหมด
            label: 'View & Edit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), // ไอคอนสำหรับค้นหา
            label: 'Search',
          ),
        ],
        currentIndex: _selectedIndex, // ใช้ค่า _selectedIndex ในการบอกตำแหน่งที่เลือก
        onTap: _onItemTapped, // เรียกใช้ฟังก์ชันเมื่อกดปุ่ม
      ),
    );
  }
}
