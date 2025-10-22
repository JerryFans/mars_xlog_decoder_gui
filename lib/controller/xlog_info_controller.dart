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

    final privateKey = this.cryptMd5.value.trim();

    if (this.isEnableCrypt.value == true &&
        (privateKey.isEmpty || privateKey.length != 64)) {
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

    final outputPath = path.join(
      savePath.value,
      "${vm.file.fileName}.log",
    );

    final execFileName =
        Platform.isWindows ? "xlog-decoder.exe" : "xlog-decoder";
    final execPath = path.join(_assetsDir.path, execFileName);

    ProcessResult process;
    if (this.isEnableCrypt.value == true) {
      //加密
      debugPrint("执行带加密key命令");
      process = await Process.run(execPath, [
        "decode",
        "-i",
        vm.file.path,
        "-p",
        privateKey.toLowerCase(),
        "-o",
        outputPath,
      ]);
    } else {
      //不加密
      debugPrint("执行不加密命令");
      process = await Process.run(execPath, [
        "decode",
        "-i",
        vm.file.path,
        "-o",
        outputPath,
      ]);
    }

    final stdoutMsg = process.stdout?.toString().trim() ?? '';
    final stderrMsg = process.stderr?.toString().trim() ?? '';
    debugPrint("xlog-decoder exitCode: ${process.exitCode}");
    if (stdoutMsg.isNotEmpty) {
      debugPrint("xlog-decoder stdout: $stdoutMsg");
    }
    if (stderrMsg.isNotEmpty) {
      debugPrint("xlog-decoder stderr: $stderrMsg");
    }

    if (process.exitCode != 0) {
      showToast("Xlog解析失败，请检查你的Private Key是否正确",
          textPadding: EdgeInsets.all(15));
      vm.updateStatus(XlogInfoStatus.fail);
      taskList.refresh();
      return;
    }

    var file = File(outputPath);

    var isExist = await file.exists();
    if (isExist) {
      final fileLength = await file.length();
      if (fileLength == 0) {
        await file.delete().catchError((_) {});
        if (this.isEnableCrypt.value == false &&
            await _decodeWithPython(vm.file.path, outputPath)) {
          file = File(outputPath);
        } else {
          showToast("Xlog解析失败：输出内容为空，请检查输入文件与私钥",
              textPadding: EdgeInsets.all(15));
          vm.updateStatus(XlogInfoStatus.fail);
          taskList.refresh();
          return;
        }
      }
      vm.saveFile = file;
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

  Future<bool> _decodeWithPython(String inputPath, String outputPath) async {
    final scriptPath = path.join(_assetsDir.path, "decode_xlog_file.py");
    final pythonCandidates = Platform.isWindows
        ? <String>["python", "py"]
        : <String>["python3", "python"];
    debugPrint("尝试使用 Python 脚本解码: $scriptPath");

    ProcessResult? result;
    String? usedCmd;
    try {
      for (final cmd in pythonCandidates) {
        try {
          debugPrint("尝试执行 Python 命令: $cmd");
          result = await Process.run(
            cmd,
            [
              scriptPath,
              inputPath,
              outputPath,
            ],
          );
          usedCmd = cmd;
          break;
        } on ProcessException catch (e) {
          debugPrint("Python 命令 $cmd 不可用: $e");
          continue;
        }
      }
      if (result == null) {
        if (Platform.isWindows) {
          showToast("未找到 Python 环境，请安装 Python 并将其加入 PATH",
              textPadding: EdgeInsets.all(15));
        }
        return false;
      }
      final stdoutMsg = result.stdout?.toString().trim() ?? '';
      final stderrMsg = result.stderr?.toString().trim() ?? '';
      debugPrint(
          "python decode (${usedCmd ?? 'unknown'}) exitCode: ${result.exitCode}");
      if (stdoutMsg.isNotEmpty) {
        debugPrint("python decode stdout: $stdoutMsg");
      }
      if (stderrMsg.isNotEmpty) {
        debugPrint("python decode stderr: $stderrMsg");
      }
      if (result.exitCode != 0) {
        return false;
      }
      final file = File(outputPath);
      if (!await file.exists()) {
        return false;
      }
      final length = await file.length();
      if (length == 0) {
        await file.delete().catchError((_) {});
        return false;
      }
      return true;
    } catch (e) {
      debugPrint("python decode error: $e");
      return false;
    }
  }
}
