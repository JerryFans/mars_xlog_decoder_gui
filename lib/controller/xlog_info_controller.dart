import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get.dart';
import 'package:mars_xlog_decoder_gui/controller/path_provider_util.dart';
import 'package:mars_xlog_decoder_gui/model/xlog_info_item_view_model.dart';
import 'dart:io';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'const_util.dart';
import 'package:path/path.dart' as path;

class XlogInfoController extends GetxController {

  static final String _assetsPath = Platform.isWindows
      ? '../data/flutter_assets/images'
      : '../../Frameworks/App.framework/Resources/flutter_assets/images';
  static File mainFile = File(Platform.resolvedExecutable);
  static Directory _assetsDir =
      Directory(path.normalize(path.join(mainFile.path, _assetsPath)));

  final PathProviderPlatform provider = PathProviderUtil.provider();
  var isEnableCrypt = true.obs;
  var taskList = <XlogInfoItemViewModel>[].obs;
  var savePath = "".obs;
  var taskCount = 0.obs;
  var cryptMd5 = ''.obs;

  void refreshWithFileList(List<File> files) {
    var vms = <XlogInfoItemViewModel>[];
    files.forEach((element) {
      vms.add(XlogInfoItemViewModel.file(element));
    });
    vms.forEach((element) {
      beginCompressTask(vm: element);
    });
    taskList.addAll(vms);
    taskCount.value = taskList.length;
  }

  void clear() {
    if (taskList.length == 0) {
      return;
    }
    taskList.assignAll([]);
    taskCount.value = 0;
  }

  void beginCompressTask({required XlogInfoItemViewModel vm}) async {

    if (savePath.value.length == 0) {
      print("save path no define");
      vm.updateStatus(XlogInfoStatus.fail);
      taskList.refresh();
      return;
    }

    print("save path : $savePath");

    var dir = await createDirectory(savePath.value);
    if (dir == null) {
      vm.updateStatus(XlogInfoStatus.fail);
      taskList.refresh();
      return;
    }

    var pyPath =  path.joinAll([
      _assetsDir.path,
      "decode_mars_python_source",
      "decode_mars_crypt_log_file"
    ]);

    await Process.run(pyPath, [
      vm.file.path,
    ]);

    var file = File(vm.file.path + ".log");
    var isExist =  await file.exists();
    if (isExist) {
      await Process.run("mv", [
        "-f",
        file.path,
        savePath.value,
      ]);
      vm.saveFile = File(path.joinAll([savePath.value,file.fileName]));
      vm.updateStatus(XlogInfoStatus.success);
      taskList.refresh();
    } else {
      vm.updateStatus(XlogInfoStatus.fail);
      taskList.refresh();
    }
  }

  Future<bool> checkHaveSavePath() async {
    var pre = await SharedPreferences.getInstance();
    return pre.getString(KXlogSavePathKey) != null;
  }

  Future<File?> createFile(String path, String fileName) async {
    try {
      bool isExist = true;
      var filePath = path + PathProviderUtil.platformDirectoryLine() + fileName;
      var count = 0;
      while (true) {
        if (count > 0) {
          var onlyName = fileName.split(".").first;
          var type = fileName.split(".").last;
          filePath = path + PathProviderUtil.platformDirectoryLine() + onlyName + "_$count" + "." + type;
        }
        isExist = await File(filePath).exists();
        print("try create path $filePath isExist $isExist");
        if (isExist == false) {
          break;
        }
        count++;
      }
      return await File(filePath).create();
    } catch (e) {
      return null;
    }
  }

  Future<Directory?> createDirectory(String path) async {
    final filePath = path;
    var file = Directory(filePath);
    try {
      bool exist = await file.exists();
      if (!exist) {
        print("no directory try create");
        return await file.create();
      } else {
        return file;
      }
    } catch (e) {
      return null;
    }
  }
}
