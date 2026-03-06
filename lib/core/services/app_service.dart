import '../models/installed_app.dart';
import 'method_channel_service.dart';

/// Service to discover apps installed on the device
class AppService {
  final MethodChannelService _channel;

  AppService({required MethodChannelService channel}) : _channel = channel;

  /// Get all user-installed apps from the device
  Future<List<InstalledApp>> getInstalledApps() async {
    return _channel.getInstalledApps();
  }
}
