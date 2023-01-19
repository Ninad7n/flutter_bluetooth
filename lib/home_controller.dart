import 'dart:async';
import 'dart:developer';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController implements GetxService {
  final SharedPreferences prefs;
  // FlutterBlue flutterBlue = FlutterBlue.instance;
  HomeController({required this.prefs});
  bool isLoading = false;
  FlutterScanBluetooth bluetoothScan = FlutterScanBluetooth();
  List<BluetoothDevice> scannedData = [];

  startScanning() async {
    if (await getPermission(Permission.bluetooth) &&
        await getPermission(Permission.bluetoothScan)) {
      try {
        isLoading = true;
        update();
        bluetoothScan.startScan();
        await Future.delayed(const Duration(seconds: 4));
        bluetoothScan.stopScan();
        bluetoothScan.devices.listen((event) {
          log("${event.address} ${event.name} ${event.paired}");
          if (!scannedData.contains(event)) {
            scannedData.add(event);
          }
        });
      } catch (e) {
        log("$e", name: "startScanning");
      }
    } else {
      AppSettings.openBluetoothSettings();
      Fluttertoast.showToast(msg: "Bluetooth is off !!");
    }
    isLoading = false;
    update();
  }

  Future<bool> getPermission(Permission permsn) async {
    var status = await permsn.request();
    log("__-----$status-----__", name: permsn.toString());
    log("$status", name: "Permission Status");
    return (await permsn.isGranted);
  }
}
