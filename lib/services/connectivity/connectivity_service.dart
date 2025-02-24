import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = false;

  ConnectivityService();

  void checkInitialConnectivity() async {
    var connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults.isNotEmpty) {
      _isConnected = _isConnectedFromResult(connectivityResults.first);
    }
  }

  bool _isConnectedFromResult(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi;
  }

  bool get isConnected => _isConnected;

  Stream<bool> get connectivityStream async* {
    await for (var resultList in _connectivity.onConnectivityChanged) {
      var result =
          resultList.isNotEmpty ? resultList.first : ConnectivityResult.none;
      _isConnected = _isConnectedFromResult(result);
      yield _isConnected;
    }
  }

  Future<bool> checkInitialConnectivitys() async {
    bool isConnected = true;
    return isConnected;
  }

  Stream<bool> get connectivityStreams {
    return Stream.value(true);
  }

  static Future<bool> hasConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }


  Stream<bool> get onConnectionChange async* {
    await for (var result in _connectivity.onConnectivityChanged) {
      yield result != ConnectivityResult.none;
    }
  }
}
