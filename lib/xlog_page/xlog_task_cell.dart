import 'dart:io';
import 'package:macos_ui/macos_ui.dart';
import 'package:mars_xlog_decoder_gui/model/xlog_info_item_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class XlogTaskCell extends StatelessWidget {
  final XlogInfoItemViewModel vm;

  XlogTaskCell({Key? key, required this.vm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vm.fileName,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    vm.statusInfo,
                    style: TextStyle(color: !MacosTheme.brightnessOf(context).isDark
                                  ? vm.statusColor
                                  : vm.darkStatusColor),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Visibility(
                  visible: vm.status == XlogInfoStatus.success,
                  child: GestureDetector(
                    onTap: () {
                      if (vm.saveFile != null) {
                        if (Platform.isMacOS) {
                          Process.run("open", ['-R', vm.saveFile!.path]);
                        } else if (Platform.isWindows) {
                          Process.run("explorer", [vm.saveFile!.path]);
                        }
                      }
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "images/folder.png",
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  )),
              _getStatusWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getStatusWidget() {
    switch (vm.status) {
      case XlogInfoStatus.processing:
        return Container(
          child: ProgressCircle(),
          width: 30,
          height: 30,
        );
      case XlogInfoStatus.fail:
        {
          return Image.asset(
            "images/error.png",
            width: 30,
            height: 30,
          );
        }
      case XlogInfoStatus.success:
        {
          return Image.asset(
            "images/success.png",
            width: 30,
            height: 30,
          );
        }
    }
  }
}
