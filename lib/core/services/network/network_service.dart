import 'package:network_info_plus/network_info_plus.dart';

class NetworkService {
  static final NetworkInfo _info = NetworkInfo();

  static Future<String?> getLocalIp() async {
    return await _info.getWifiIP(); // e.g. 192.168.1.10
  }

  static Future<String?> getWifiName() async {
    return await _info.getWifiName();
  }
}
