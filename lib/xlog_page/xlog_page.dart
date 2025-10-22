import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mars_xlog_decoder_gui/controller/const_util.dart';
import 'package:mars_xlog_decoder_gui/controller/path_provider_util.dart';
import 'package:mars_xlog_decoder_gui/controller/xlog_info_controller.dart';
import 'package:mars_xlog_decoder_gui/xlog_page/xlog_task_cell.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class XlogPage extends StatefulWidget {
  XlogPage({Key? key}) : super(key: key);

  @override
  State<XlogPage> createState() => _XlogPageState();
}

class _XlogPageState extends State<XlogPage> {
  final controller = XlogInfoController();
  var visibilityTips = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((pre) async {
      var isEnableCrypt = pre.getBool(KEnableCryptKey);
      if (isEnableCrypt == null) {
        pre.setBool(KEnableCryptKey, true);
      } else {
        controller.isEnableCrypt.value = isEnableCrypt;
      }
      var privateKey = pre.getString(KCryptPrivateKey);
      if (privateKey != null) {
        controller.cryptMd5.value = privateKey;
      }
      var savePath = pre.getString(KXlogSavePathKey);
      if (savePath == null || savePath.isEmpty) {
        try {
          var provider = PathProviderUtil.provider();
          final downloadsPath = await provider.getDownloadsPath();
          if (downloadsPath != null && downloadsPath.isNotEmpty) {
            print("get down path $downloadsPath");
            final separator = PathProviderUtil.platformDirectoryLine();
            final filePath = downloadsPath + separator + "XlogOutput";
            pre.setString(KXlogSavePathKey, filePath);
            controller.savePath.value = filePath;
          }
        } catch (e) {}
      } else {
        controller.savePath.value = savePath;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      titleBar: TitleBar(
        title: Text('Xlog Decode'),
      ),
      children: [
        ContentArea(builder: (builder, scrollControler) {
          return Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    color: !MacosTheme.brightnessOf(context).isDark
                        ? CupertinoColors.systemGrey6.color
                        : CupertinoColors.tertiarySystemBackground.darkColor,
                    height: 66,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('PRIVATE_KEY'),
                            SizedBox(
                              width: 15,
                            ),
                            Container(
                              width: 300,
                              height: 35,
                              child: Obx(() => MacosTextField(
                                    placeholder: controller.cryptMd5.value,
                                    onChanged: (v) {
                                      controller.cryptMd5.value = v;
                                      SharedPreferences.getInstance()
                                          .then((pre) async {
                                        pre.setString(KCryptPrivateKey, v);
                                      });
                                    },
                                  )),
                            ),
                          ],
                        ),
                        Obx(
                          () => Row(
                            children: [
                              PushButton(
                                buttonSize: ButtonSize.large,
                                child: Text('使用帮助'),
                                onPressed: () async {
                                  showMacosAlertDialog(
                                    barrierDismissible: true,
                                    useRootNavigator: false,
                                    context: context,
                                    builder: (context) => MacosAlertDialog(
                                      appIcon: Image.asset(
                                        "images/app_icon.png",
                                        width: 64,
                                        height: 64,
                                      ),
                                      title: Text(
                                        '提示',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                      message: Text(
                                        '项目根目录中xlog_ios_demo 文件夹 为iOS 事例程序，已配置默认pub_key对应private_key为 145aa7717bf9745b91e9569b80bbf1eedaa6cc6cd0e26317d810e35710f44cf8 。如有需要可点击生成 RSA Key重新生成，生成后修改示例程序JRXlogManager 文件中pub_key即可。',
                                      ),
                                      horizontalActions: false,
                                      primaryButton: PushButton(
                                        buttonSize: ButtonSize.large,
                                        child: const Text('复制Private Key'),
                                        onPressed: () {
                                          ClipboardData data = ClipboardData(
                                              text:
                                                  "145aa7717bf9745b91e9569b80bbf1eedaa6cc6cd0e26317d810e35710f44cf8");
                                          Clipboard.setData(data);
                                          controller.cryptMd5.value =
                                              "145aa7717bf9745b91e9569b80bbf1eedaa6cc6cd0e26317d810e35710f44cf8";
                                          SharedPreferences.getInstance()
                                              .then((pre) async {
                                            pre.setString(KCryptPrivateKey,
                                                "145aa7717bf9745b91e9569b80bbf1eedaa6cc6cd0e26317d810e35710f44cf8");
                                          });
                                          showToast("已复制到粘贴板及复制Private Key 文本框",
                                              textPadding: EdgeInsets.all(15));
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      secondaryButton: PushButton(
                                        buttonSize: ButtonSize.large,
                                        child: const Text('知道了'),
                                        onPressed: Navigator.of(context).pop,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              PushButton(
                                buttonSize: ButtonSize.large,
                                child: Text('生成 RSA Key'),
                                onPressed: () async {
                                  var result = await controller.genKey();
                                  showMacosAlertDialog(
                                    barrierDismissible: true,
                                    useRootNavigator: false,
                                    context: context,
                                    builder: (context) => MacosAlertDialog(
                                      appIcon: Image.asset(
                                        "images/app_icon.png",
                                        width: 64,
                                        height: 64,
                                      ),
                                      title: Text(
                                        '请记住你生成的RSA Key',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                      message: Text(
                                        result,
                                      ),
                                      horizontalActions: false,
                                      primaryButton: PushButton(
                                        buttonSize: ButtonSize.large,
                                        child: const Text('复制'),
                                        onPressed: () {
                                          ClipboardData data =
                                              ClipboardData(text: result);
                                          Clipboard.setData(data);
                                          showToast("已复制到粘贴板",
                                              textPadding: EdgeInsets.all(15));
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      secondaryButton: PushButton(
                                        buttonSize: ButtonSize.large,
                                        child: const Text('取消'),
                                        onPressed: Navigator.of(context).pop,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text("开启RSA加密"),
                              SizedBox(
                                width: 15,
                              ),
                              MacosCheckbox(
                                value: controller.isEnableCrypt.value,
                                onChanged: (isEnbale) {
                                  controller.isEnableCrypt.value = isEnbale;
                                  if (isEnbale == false) {
                                    showMacosAlertDialog(
                                      barrierDismissible: true,
                                      useRootNavigator: false,
                                      context: context,
                                      builder: (context) => MacosAlertDialog(
                                        appIcon: Image.asset(
                                          "images/app_icon.png",
                                          width: 64,
                                          height: 64,
                                        ),
                                        title: Text(
                                          '提示',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                        message: Text(
                                          '请确认 XLogConfig 类中 pub_key 为空串。 此方法为不加密日志内容有泄露风险，请慎用。',
                                        ),
                                        horizontalActions: false,
                                        primaryButton: PushButton(
                                          buttonSize: ButtonSize.large,
                                          child: const Text('知道了'),
                                          onPressed: Navigator.of(context).pop,
                                        ),
                                      ),
                                    );
                                  }
                                  SharedPreferences.getInstance().then(
                                      (value) => value.setBool(
                                          KEnableCryptKey, isEnbale));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              DropTarget(
                onDragDone: (detail) {
                  checkCanPicker().then((canPicker) async {
                    if (canPicker) {
                      var collectionFiles = <File>[];
                      for (var e in detail.files) {
                        var dir = Directory(e.path);
                        if (await dir.exists() == true) {
                          print("is dir");
                          for (var element in dir.listSync()) {
                            var file = File(element.path);
                            collectionFiles.add(file);
                          }
                        } else {
                          var file = File(e.path);
                          collectionFiles.add(file);
                        }
                      }
                      var chooseFiles = chooseXlogFiles(collectionFiles);
                      if (chooseFiles.isNotEmpty) {
                        controller.refreshWithFileList(chooseFiles);
                      } else {
                        showToast(
                            "Please drag a xlog file or xlog directory here",
                            textPadding: EdgeInsets.all(15));
                      }
                    }
                  });
                },
                onDragEntered: (details) {
                  setState(() {
                    visibilityTips = true;
                  });
                },
                onDragExited: (details) {
                  setState(() {
                    visibilityTips = false;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(top: 66 + 15, bottom: 80),
                  child: Obx(() {
                    if (controller.taskList.length > 0) {
                      return ListView.separated(
                        itemCount: controller.taskList.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            height: 15,
                            color: Colors.transparent,
                          );
                        },
                        itemBuilder: (_, int index) => XlogTaskCell(
                          vm: controller.taskList[index],
                        ),
                      );
                    } else {
                      return Container(
                        child: Center(
                          child: TextButton(
                            child: Text(
                              "Add or Drag Log File Here",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              _pickFiles();
                            },
                          ),
                        ),
                      );
                    }
                  }),
                ),
              ),
              Positioned(
                  right: 15,
                  bottom: 15,
                  child: Row(
                    children: [
                      MacosIconButton(
                        backgroundColor: Colors.grey,
                        onPressed: () async {
                          var savePath = controller.savePath.value;
                          if (savePath.length == 0) {
                            showToast("save path is null");
                            return;
                          }
                          var checkCreate =
                              await controller.createDirectory(savePath);
                          if (checkCreate != null) {
                            if (Platform.isMacOS) {
                              Process.run("open", [savePath]);
                            } else if (Platform.isWindows) {
                              Process.run("explorer", [savePath]);
                            }
                          }
                        },
                        icon: MacosIcon(
                          CupertinoIcons.folder,
                          color: Colors.white,
                        ),
                        shape: BoxShape.circle,
                        //onPressed: () {},
                      ),
                    ],
                  )),
              Visibility(
                visible: visibilityTips,
                child: Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black54,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 45,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            padding: EdgeInsets.all(15),
                            child: Text(
                              "Drag your log file Here",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )),
              )
            ],
          );
        }),
      ],
    );
  }

  void _pickFiles() async {
    if (await checkCanPicker() == false) {
      return;
    }
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      List<File> files = result.paths.map((path) => File(path ?? "")).toList();
      List<File> chooseFiles = chooseXlogFiles(files);
      if (chooseFiles.isNotEmpty) {
        controller.refreshWithFileList(chooseFiles);
      }
    } else {
      showToast("Cancel Pick files", textPadding: EdgeInsets.all(15));
    }
  }

  List<File> chooseXlogFiles(List<File> receiverFiles) {
    List<File> chooseFiles = [];
    receiverFiles.forEach((element) {
      if (element.path.toLowerCase().endsWith(".xlog")) {
        chooseFiles.add(element);
      }
    });
    return chooseFiles;
  }

  Future<bool> checkCanPicker() async {
    return true;
  }
}
