import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'b_model.dart';

class HomeController extends GetxController implements GetxService {
  final SharedPreferences prefs;
  // FlutterBlue flutterBlue = FlutterBlue.instance;
  HomeController({required this.prefs});
  bool isLoading = false;
  FlutterScanBluetooth bluetoothScan = FlutterScanBluetooth();
  List<BluetoothData> scannedData = [];

  getData() {
    if (scannedData.isNotEmpty && prefs.containsKey('b_data')) {
      scannedData =
          bluetoothDataFromJson(jsonDecode(prefs.getString("b_data")!));
    }

    update();
  }

  setData() {
    prefs.setString("b_data", jsonEncode(bluetoothDataToJson(scannedData)));
  }

  startScanning() async {
    if (await getPermission(Permission.bluetooth) &&
        await getPermission(Permission.bluetoothScan)) {
      try {
        scannedData.clear();
        isLoading = true;
        update();
        bluetoothScan.startScan();
        await Future.delayed(const Duration(seconds: 4));
        bluetoothScan.stopScan();
        bluetoothScan.devices.listen((event) {
          var data = BluetoothData(
              name: event.name, address: event.address, isPaired: event.paired);
          if (scannedData.indexWhere((element) =>
                  element.name.toString() == data.name.toString()) ==
              -1) {
            scannedData.add(data);
          }
        });
        log(bluetoothDataToJson(scannedData));
      } catch (e) {
        log("$e", name: "startScanning");
      }
      if (scannedData.isEmpty) {
        Fluttertoast.showToast(msg: "Not data found, try again");
      }
      setData();
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
