import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'database.db');
    return await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE plant(
          plantID INTEGER PRIMARY KEY AUTOINCREMENT,
          plantName TEXT,
          plantScientific TEXT,
          plantImage TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE plantComponent(
          componentID INTEGER PRIMARY KEY AUTOINCREMENT,
          componentName TEXT,
          componentIcon TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE LandUseType(
          LandUseTypeID INTEGER PRIMARY KEY AUTOINCREMENT,
          LandUseTypeName TEXT,
          LandUseTypeDescription TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE LandUse(
          LandUseID INTEGER PRIMARY KEY AUTOINCREMENT,
          plantID INTEGER,
          componetnID INTEGER,
          LandUseTypeID INTEGER,
          LandUseDescription TEXT,
          FOREIGN KEY (plantID) REFERENCES plant(plantID),
          FOREIGN KEY (componentID) REFERENCES plantComponent(componentID),
          FOREIGN KEY (LandUseTypeID) REFERENCES LandUseType(LandUseTypeID)
        )
        ''');

        // ข้อมูลสำหรับตาราง plantComponent
        await db.insert('plantComponent', {
          'componentID': 1101,
          'componentName': 'Leaf',
          'componentIcon': 'leaf.png',
        });
        await db.insert('plantComponent', {
          'componentID': 1102,
          'componentName': 'Flower',
          'componentIcon': 'flower.png',
        });
        await db.insert('plantComponent', {
          'componentID': 1103,
          'componentName': 'Fruit',
          'componentIcon': 'fruit.png',
        });
        await db.insert('plantComponent', {
          'componentID': 1104,
          'componentName': 'Stem',
          'componentIcon': 'stem.png',
        });
        await db.insert('plantComponent', {
          'componentID': 1105,
          'componentName': 'Root',
          'componentIcon': 'root.png',
        });
      },
      version: 1,
    );
  }

  // ฟังก์ชันบันทึกข้อมูลตาราง LandUse
  Future<void> insertLandUse({
    required String plantName,
    required String plantScientific,
    required String landUseDescription,
    required String plantImage,
    required String componentName,
    required String landUseTypeName,
    required String landUseTypeDescription,
  }) async {
    final db = await database;

    // ค้นหา componentID
    var componentResult = await db.query('plantComponent',
        where: 'componentName = ?', whereArgs: [componentName]);

    // เช็คว่ามี componentID หรือไม่
    if (componentResult.isEmpty) {
      throw Exception('Component not found');
    }
    
    int componentId = componentResult.first['componentID'] as int;

    // บันทึกข้อมูลลงในตาราง LandUseType 
    int landUseTypeId = await db.insert('LandUseType', {
      'LandUseTypeName': landUseTypeName,
      'LandUseTypeDescription': landUseTypeDescription,
    });

    // บันทึกข้อมูลลงในตาราง Plant
    int plantId = await db.insert('plant', {
      'plantName': plantName,
      'plantScientific': plantScientific,
      'plantImage': plantImage,
    });

    // บันทึกข้อมูลลงในตาราง LandUse
    await db.insert('LandUse', {
      'plantID': plantId,
      'componentID': componentId, // ใช้ componentId ที่ค้นพบ
      'LandUseTypeID': landUseTypeId,
      'LandUseDescription': landUseDescription,
    });
  }

  // ฟังก์ชันเรียกแสดงข้อมูลทั้งหมดจากตาราง plant
  Future<List<Map<String, dynamic>>> getAllPlants() async {
    final db = await database;
    return await db.query('plant');
  }

  // ฟังก์ชันเรียกแสดงข้อมูลตารางทั้งหมด
  Future<Map<String, dynamic>> getPlantDetails(int plantID) async {
    final db = await database;

    // ดึงข้อมูลจากตาราง LandUse โดยใช้ plantID
    var landUseResults = await db.query('LandUse', where: 'plantID = ?', whereArgs: [plantID]);

    if (landUseResults.isNotEmpty) {
      var landUse = landUseResults.first;

      // ดึงข้อมูลจากตาราง LandUseType โดยใช้ LandUseTypeID
      var landUseTypeResults = await db.query('LandUseType', where: 'LandUseTypeID = ?', whereArgs: [landUse['LandUseTypeID']]);

      // ดึงข้อมูลจากตาราง Plant โดยใช้ plantID
      var plantResults = await db.query('plant', where: 'plantID = ?', whereArgs: [plantID]);
      String plantName = plantResults.isNotEmpty ? (plantResults.first['plantName'] as String?) ?? 'Plant name not available' : 'Plant not found';
      String plantScientific = plantResults.isNotEmpty ? (plantResults.first['plantScientific'] as String?) ?? 'Scientific name not available' : 'Scientific name not available';
      String plantImage = plantResults.isNotEmpty ? (plantResults.first['plantImage'] as String?) ?? 'Image not available' : 'Image not available';

      // ดึง LandUseTypeName
      String landUseTypeName = landUseTypeResults.isNotEmpty
          ? (landUseTypeResults.first['LandUseTypeName'] as String?) ?? 'Land use type not available'
          : 'Land use type not available';
      
      // ดึง LandUseTypeDescription
      String landUseTypeDescription = landUseTypeResults.isNotEmpty
          ? (landUseTypeResults.first['LandUseTypeDescription'] as String?) ?? 'Description not available'
          : 'Description not available';

      return {
        'plantName': plantName,
        'plantScientific': plantScientific,
        'plantImage': plantImage,
        'landUseDescription': landUse['LandUseDescription'] ?? 'Description not available',
        'landUseTypeName': landUseTypeName,
        'landUseTypeDescription': landUseTypeDescription,
      };
    }

    return {
      'plantName': 'Plant not found',
      'plantScientific': 'Scientific name not available',
      'plantImage': 'Image not available',
      'landUseDescription': 'Land use not available',
      'landUseTypeName': 'Land use type not available',
      'landUseTypeDescription': 'Description not available',
    };
  }

  // ฟังก์ชันลบข้อมูลพืชและข้อมูลที่เกี่ยวข้องทั้งหมด
  Future<void> deletePlant(int plantId) async {
    final db = await database;

    // ค้นหา LandUseID ที่เชื่อมโยงกับ plantID นี้
    final landUseResults = await db.query('LandUse', where: 'plantID = ?', whereArgs: [plantId]);

    // ลบข้อมูลจาก LandUse ที่มี plantID นี้
    await db.delete('LandUse', where: 'plantID = ?', whereArgs: [plantId]);

    // ใช้ LandUseID เพื่อลบข้อมูลที่เชื่อมโยงในตารางอื่น (ถ้ามี)
    for (var landUse in landUseResults) {
      // ตรวจสอบและแคสต์ค่า LandUseID ให้เป็น int
      int landUseId = (landUse['LandUseID'] as int? ?? 0); // ใช้ค่า 0 หากเป็น null
      // ตารางอื่นที่เชื่อมโยงกับ LandUseID
      await db.delete('OtherTable', where: 'LandUseID = ?', whereArgs: [landUseId]);
    }
    // 4. ลบข้อมูลจาก Plant
    await db.delete('plant', where: 'plantID = ?', whereArgs: [plantId]);
  }

  // ฟังก์ชันที่ใช้สำหรับอัปเดตพืช
  Future<int> updatePlant(int plantID, Map<String, dynamic> plantData) async {
    final db = await database;
    return await db.update(
      'plants', // ชื่อของตาราง
      plantData, // ข้อมูลที่ต้องการอัปเดต
      where: 'plantID = ?', 
      whereArgs: [plantID],
    );
  }

  Future<List<Map<String, dynamic>>> searchPlantsByName(String plantName) async {
    final db = await database;
    return await db.query(
      'plant',
      where: 'plantName LIKE ?',
      whereArgs: ['%$plantName%'],
    );
  }

}
 