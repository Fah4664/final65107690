import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'plant_detail_screen.dart';

class SearchPlantScreen extends StatefulWidget {
  @override
  _SearchPlantScreenState createState() => _SearchPlantScreenState();
}

class _SearchPlantScreenState extends State<SearchPlantScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  void _searchPlants() async {
    final results = await _dbHelper.searchPlantsByName(_searchController.text);
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Plants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter plant name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchPlants,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final plant = _searchResults[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlantDetailScreen(plant: plant)),
                      );
                    },
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
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
            ),
          ),
        ],
      ),
    );
  }
}
