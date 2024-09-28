import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'plant_detail_screen.dart';

class ViewScreen extends StatefulWidget {
  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
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
        title: Text('All Plant Information'), 
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
                child: GestureDetector(
                  onTap: () {
                    // นำทางไปยังหน้าจอรายละเอียดพืช
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PlantDetailScreen(plant: plant)),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: plant['plantImage'] != null
                                    ? ClipRect(
                                        child: Image.network(
                                          plant['plantImage'],
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(Icons.nature),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${plant['plantName']} : ${plant['plantScientific']}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
