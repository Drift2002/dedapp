import 'package:app_usage/app_usage.dart';

class ScreenTimeService {
  Future<Duration> getDailyScreenTime() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 1));

      // Calculate total usage for the last 24 hours
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(
        startDate,
        endDate,
      );

      Duration totalDuration = Duration.zero;
      for (var info in infoList) {
        totalDuration += info.usage;
      }
      return totalDuration;
    } catch (exception) {
      print(exception);
      // If permission is not granted, this might throw.
      // The caller should handle this or prompt user.
      return Duration.zero;
    }
  }
}
