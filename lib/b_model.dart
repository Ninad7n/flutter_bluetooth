import 'dart:convert';

List<BluetoothData> bluetoothDataFromJson(String str) =>
    List<BluetoothData>.from(
        json.decode(str).map((x) => BluetoothData.fromJson(x)));

String bluetoothDataToJson(List<BluetoothData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BluetoothData {
  BluetoothData({
    this.name,
    this.address,
    this.isPaired,
  });

  String? name;
  String? address;
  bool? isPaired;

  factory BluetoothData.fromJson(Map<String, dynamic> json) => BluetoothData(
        name: json["name"],
        address: json["address"],
        isPaired: json["isPaired"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "address": address,
        "isPaired": isPaired,
      };
}
