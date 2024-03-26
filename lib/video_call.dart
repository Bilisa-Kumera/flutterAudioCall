import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:device_info/device_info.dart';
import 'video_call_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<Database> _initDatabase() async {
    // Open the database and create the table if it doesn't exist
    return openDatabase(
      join(await getDatabasesPath(), 'devices_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE devices(id INTEGER PRIMARY KEY, deviceId TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> _generateAndSaveToken(BuildContext context) async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId;
    try {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor; // For iOS, this is the device ID
      } else {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.androidId; // For Android, this is the device ID
      }

      // Save the device ID to the database
      final Database db = await _initDatabase();
      await db.insert(
        'devices',
        {'deviceId': deviceId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      ).then((value) {
        print('value $value');
      });

      print('token $deviceId');

      // Navigate to the video call screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => VideoCallScreen(token: deviceId)),
      // );
    } catch (e) {
      print('Failed to get device ID: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.video_call),
          label: const Text('JOIN CALL CHANNEL'),
          onPressed: () async {
            await _generateAndSaveToken(context);
          },
        ),
      ),
    );
  }
}
