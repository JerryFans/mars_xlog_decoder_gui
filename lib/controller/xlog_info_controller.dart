import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mars_xlog_decoder_gui/controller/path_provider_util.dart';
import 'package:mars_xlog_decoder_gui/model/xlog_info_item_view_model.dart';
import 'package:oktoast/oktoast.dart';
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
  var stringList = <String>[].obs;
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

  Future<String> genKey() async {
    var pyPath = path.joinAll([
      _assetsDir.path,
      Platform.isWindows ? "xlog-decoder.exe" : "xlog-decoder",
    ]);
    var process = await Process.run(pyPath, ["gen-key"]);
    print("result:\n");
    print(process.stdout);
    return process.stdout
        .toString()
        .split("\n")[0]
        .split("private_key:")[1]
        .trim();
  }

  void beginCompressTask({required XlogInfoItemViewModel vm}) async {
    if (savePath.value.length == 0) {
      print("save path no define");
      vm.updateStatus(XlogInfoStatus.fail);
      taskList.refresh();
      return;
    }

    if (this.isEnableCrypt.value == true &&
        (this.cryptMd5.value.isEmpty || this.cryptMd5.value.length != 64)) {
      print("private key is empty");
      showToast("Private Key 为空或长度不对（64位）", textPadding: EdgeInsets.all(15));
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

    var execFileName = Platform.isWindows ? "xlog-decoder.exe" : "xlog-decoder";
    var pyPath = path.joinAll([
      _assetsDir.path,
      execFileName,
    ]);
    if (this.isEnableCrypt.value == false) {
      pyPath = path.joinAll([_assetsDir.path, execFileName]);
    }

    List<String> args = <String>[vm.file.path];
    if (this.isEnableCrypt.value == true) {
      args.insert(0, this.cryptMd5.value);
    }

    var process = await Process.run(
      pyPath,
      [
        "decode",
        "-i",
        vm.file.path,
        "-p",
        this.cryptMd5.value,
        "-o",
        "${vm.file.path}.log"
      ],
    );

    if (process.exitCode != 0) {
      showToast("Xlog解析失败，请检查你的Private Key是否正确",
          textPadding: EdgeInsets.all(15));
      vm.updateStatus(XlogInfoStatus.fail);
      taskList.refresh();
      return;
    }

    var file = File(vm.file.path + ".log");

    var isExist = await file.exists();
    if (isExist) {
      Platform.isWindows
          ? await Process.run("xcopy", [
              file.path,
              savePath.value,
              "/y",
            ])
          : await Process.run("cp", [
              "-f",
              file.path,
              savePath.value,
            ]);
      vm.saveFile = File(path.joinAll([savePath.value, file.fileName]));
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
          filePath = path +
              PathProviderUtil.platformDirectoryLine() +
              onlyName +
              "_$count" +
              "." +
              type;
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
