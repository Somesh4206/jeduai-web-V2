import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

/// App Update Service - Checks for new versions and prompts user to update
class AppUpdateService extends GetxService {
  // Update this URL to point to your version info JSON file
  static const String versionCheckUrl =
      'https://raw.githubusercontent.com/kathirvel-p22/JeduAi/main/version.json';

  final RxBool isUpdateAvailable = false.obs;
  final RxString latestVersion = ''.obs;
  final RxString downloadUrl = ''.obs;
  final RxString updateMessage = ''.obs;

  /// Check for updates on app startup
  Future<void> checkForUpdates({bool showNoUpdateDialog = false}) async {
    try {
      print('🔍 Checking for app updates...');

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      print('📱 Current version: $currentVersion');

      // Fetch latest version info from server
      final response = await http
          .get(Uri.parse(versionCheckUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final versionInfo = jsonDecode(response.body);
        final serverVersion = versionInfo['version'] as String;
        final serverDownloadUrl = versionInfo['downloadUrl'] as String;
        final serverMessage =
            versionInfo['message'] as String? ?? 'A new version is available!';

        print('🌐 Latest version: $serverVersion');

        // Compare versions
        if (_isNewerVersion(currentVersion, serverVersion)) {
          latestVersion.value = serverVersion;
          downloadUrl.value = serverDownloadUrl;
          updateMessage.value = serverMessage;
          isUpdateAvailable.value = true;

          print('✅ Update available: $serverVersion');
          _showUpdateDialog();
        } else {
          print('✅ App is up to date');
          if (showNoUpdateDialog) {
            Get.snackbar(
              'Up to Date',
              'You are using the latest version',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        }
      } else {
        print('⚠️ Failed to check for updates: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error checking for updates: $e');
      // Silently fail - don't bother user if update check fails
    }
  }

  /// Compare version strings (e.g., "1.0.0" vs "1.0.1")
  bool _isNewerVersion(String current, String server) {
    final currentParts = current.split('.').map(int.parse).toList();
    final serverParts = server.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final serverPart = i < serverParts.length ? serverParts[i] : 0;

      if (serverPart > currentPart) return true;
      if (serverPart < currentPart) return false;
    }

    return false;
  }

  /// Show update dialog to user
  void _showUpdateDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.system_update, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text('Update Available'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(updateMessage.value, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Version:'),
                      Text(
                        'v${Get.find<PackageInfo>().version}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Latest Version:'),
                      Text(
                        'v${latestVersion.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Later')),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _downloadUpdate();
            },
            icon: Icon(Icons.download),
            label: Text('Update Now'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Open download URL in browser
  Future<void> _downloadUpdate() async {
    try {
      final uri = Uri.parse(downloadUrl.value);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        Get.snackbar(
          'Downloading Update',
          'Please install the downloaded APK',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        throw 'Could not launch $downloadUrl';
      }
    } catch (e) {
      print('❌ Error downloading update: $e');
      Get.snackbar(
        'Error',
        'Could not open download link',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Manual update check (called from settings)
  Future<void> manualUpdateCheck() async {
    Get.dialog(
      Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Checking for updates...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    await checkForUpdates(showNoUpdateDialog: true);
    Get.back(); // Close loading dialog
  }
}
