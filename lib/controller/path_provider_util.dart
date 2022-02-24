import 'dart:io';
import 'package:path_provider_macos/path_provider_macos.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider_windows/path_provider_windows.dart';

class PathProviderUtil {
  static PathProviderPlatform provider() {
    if (Platform.isMacOS) {
      final PathProviderPlatform provider = PathProviderMacOS();
       return provider;
    } else if (Platform.isWindows) {
      final PathProviderPlatform provider = PathProviderWindows();
      return provider;
    }
    return PathProviderPlatform.instance;
  }

  static String platformDirectoryLine() {
    if (Platform.isWindows) {
      return "\\";
    }
    return "/";
  }
}