import 'dart:io';
import 'package:wifi_iot/wifi_iot.dart';

class WifiClientService {
  Future<void> connectToHotspot(String ssid, String password) async {
    await WiFiForIoTPlugin.connect(
      ssid,
      password: password,
      security: NetworkSecurity.WPA,
      joinOnce: true,
    );
  }

  Future<Socket> connectToServer(String ip, int port) async {
    return await Socket.connect(ip, port);
  }
}
