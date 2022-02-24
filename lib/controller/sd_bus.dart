import 'package:event_bus/event_bus.dart';

class MenuClickInfo {
  String action;
  MenuClickInfo(this.action);
}


class SDBus {
  static EventBus? _eventBus;
  /// 单例模式
  static EventBus getInstance() {
    // 只能有一个实例
    if (_eventBus == null) {
      _eventBus = EventBus();
    }
    return _eventBus!;
  }
}
