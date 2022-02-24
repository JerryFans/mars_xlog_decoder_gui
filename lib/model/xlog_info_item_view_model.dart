import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mars_xlog_decoder_gui/controller/path_provider_util.dart';

extension FileExtention on FileSystemEntity {
  String get fileName {
    print("my file path is ${this.path}");
    return this.path.split(PathProviderUtil.platformDirectoryLine()).last;
  }
}

enum XlogInfoStatus {
  processing,
  fail,
  success
}

class XlogInfoItemViewModel {
  File file;
  String fileName = "";
  String statusInfo = "Processing";
  Color  statusColor = Colors.black54;
  Color  darkStatusColor = Colors.white54;
  XlogInfoStatus status = XlogInfoStatus.processing;
  File? saveFile;

  void updateStatus(XlogInfoStatus status) {
    this.status = status;
    print("setting status");
    switch (status) {
      case XlogInfoStatus.processing:
        statusInfo = "Processing";
        statusColor = Colors.black54;
        darkStatusColor = Colors.white54;
        break;
      case XlogInfoStatus.fail:
        statusInfo = "Fail";
        statusColor = Colors.red;
        darkStatusColor = statusColor;
        break;
      case XlogInfoStatus.success: {
        statusInfo = "Success";
        statusColor = Colors.greenAccent;
        darkStatusColor = statusColor;
      }
        break;
    }
  }

  XlogInfoItemViewModel.file(this.file) {
    this.fileName = file.fileName;
  }
}
