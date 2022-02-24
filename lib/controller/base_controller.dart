import 'dart:async';

import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:mars_xlog_decoder_gui/controller/sd_bus.dart';

class BaseController extends GetxController {

  BaseController() {
    registerEventBus();
  }

  var _subscriptionList = <StreamSubscription>[];

  void subscriptEvent<T>(void subscription(T event)) {
    _subscriptionList.add(SDBus.getInstance().on<T>().listen((event) {
      subscription(event);
    }));
  }

  void unRegisterEventBus() {
    _subscriptionList.forEach((element) {
      element.cancel();
    });
    _subscriptionList.clear();
  }

  @override
  void onClose() {
    super.onClose();
    unRegisterEventBus();
    print('BaseController--onClose');
  }

  void registerEventBus() {}
}