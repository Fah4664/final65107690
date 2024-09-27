import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
//import '../models/plant.dart'; // นำเข้าโมเดล Plant
//import '../models/land_use.dart'; // นำเข้าโมเดล LandUse
//import '../models/land_use_type.dart'; // นำเข้าโมเดล LandUseType

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
    String path = join(await getDatabasesPath(), 'datadase.db');
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
          componetID INTEGER PRIMARY KEY AUTOINCREMENT,
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
          componetID INTEGER,
          LandUseTypeID INTEGER,
          LandUseDescription TEXT,
          FOREIGN KEY (plantID) REFERENCES plant(plantID),
          FOREIGN KEY (componetID) REFERENCES plantComponent(componetID),
          FOREIGN KEY (LandUseTypeID) REFERENCES LandUseType(LandUseTypeID)
        )
        ''');

        // ข้อมูลเริ่มต้นสำหรับ plantComponent
        await db.insert('plantComponent', {
          'componetID': 1101,
          'componentName': 'Leaf',
          'componentIcon': 'leaf_icon.png',
        });
        await db.insert('plantComponent', {
          'componetID': 1102,
          'componentName': 'Flower',
          'componentIcon': 'flower_icon.png',
        });
        await db.insert('plantComponent', {
          'componetID': 1103,
          'componentName': 'Fruit',
          'componentIcon': 'fruit_icon.png',
        });
        await db.insert('plantComponent', {
          'componetID': 1104,
          'componentName': 'Stem',
          'componentIcon': 'stem_icon.png',
        });
        await db.insert('plantComponent', {
          'componetID': 1105,
          'componentName': 'Root',
          'componentIcon': 'root_icon.png',
        });

        // ข้อมูลเริ่มต้นสำหรับ LandUseType
        await db.insert('LandUseType', {
          'LandUseTypeID': 1301,
          'LandUseTypeName': 'Food',
          'LandUseTypeDescription': 'Used as food or ingredients',
        });
        await db.insert('LandUseType', {
          'LandUseTypeID': 1302,
          'LandUseTypeName': 'Medicine',
          'LandUseTypeDescription': 'Used for medicinal purposes',
        });
        await db.insert('LandUseType', {
          'LandUseTypeID': 1303,
          'LandUseTypeName': 'Insecticide',
          'LandUseTypeDescription': 'Used to repel insects',
        });
        await db.insert('LandUseType', {
          'LandUseTypeID': 1304,
          'LandUseTypeName': 'Construction',
          'LandUseTypeDescription': 'Used in building materials',
        });
        await db.insert('LandUseType', {
          'LandUseTypeID': 1305,
          'LandUseTypeName': 'Culture',
          'LandUseTypeDescription': 'Used in traditional practices',
        });
      },
      version: 1,
    );
  }

   // ฟังก์ชันบันทึกข้อมูลการใช้ประโยชน์
  Future<void> insertLandUse({
    required String plantName,
    required String plantScientific,
    required String landUseDescription,
    required String plantImage,
    required String componentName,
    required String landUseTypeName,
  }) async {
    final db = await database;
    final plants = await db.query('plant'); // ตรวจสอบข้อมูลในตาราง plant
    print(plants); // ตรวจสอบว่ามีข้อมูลถูกบันทึกหรือไม่

    // ขั้นตอนที่ 1: บันทึกข้อมูลลงในตาราง plant
    final plantId = await db.insert('plant', {
      'plantName': plantName,
      'plantScientific': plantScientific,
      'plantImage': plantImage,
    });

    // ขั้นตอนที่ 2: บันทึกข้อมูลลงในตาราง plantComponent
    final componentId = await db.insert('plantComponent', {
      'componentName': componentName,
      // ถ้าต้องการข้อมูลเพิ่มเติมเกี่ยวกับ component ให้เพิ่มที่นี่
    });

    // ขั้นตอนที่ 3: บันทึกข้อมูลลงในตาราง LandUseType
    final landUseTypeId = await db.insert('LandUseType', {
      'LandUseTypeName': landUseTypeName,
      // ถ้าต้องการข้อมูลเพิ่มเติมเกี่ยวกับ LandUseType ให้เพิ่มที่นี่
    });

    // ขั้นตอนที่ 4: บันทึกข้อมูลลงในตาราง LandUse
    await db.insert('LandUse', {
      'plantID': plantId,
      'componetID': componentId,
      'LandUseTypeID': landUseTypeId,
      'LandUseDescription': landUseDescription,
    });
  }

  // ฟังก์ชันดึงข้อมูลพืชทั้งหมดจากตาราง plant
  Future<List<Map<String, dynamic>>> getAllPlants() async {
    final db = await database;
    return await db.query('plant'); // ดึงข้อมูลทั้งหมดจากตาราง plant
  }

  // ฟังก์ชันลบพืช
  Future<void> deletePlant(int plantID) async {
    final db = await database;
    // ลบข้อมูลจากตาราง plant
    await db.delete(
      'plant',
      where: 'plantID = ?',
      whereArgs: [plantID],
    );
  }

}

 