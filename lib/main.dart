import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mars_xlog_decoder_gui/theme.dart';
import 'package:mars_xlog_decoder_gui/xlog_page/xlog_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setResizable(false);
    await windowManager.setSize(Size(1064, 800));
    await windowManager.show();
  });
  runApp(GetMaterialApp(
    navigatorKey: Get.key,
    home: OKToast(
      child: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return MacosApp(
          title: 'SD Dev Tool',
          theme: MacosThemeData.light(),
          darkTheme: MacosThemeData.dark(),
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          home: MyHomePage(
            title: 'SD Dev Tool',
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int pageIndex = 0;

  final List<Widget> pages = [
    XlogPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      child: IndexedStack(
        index: pageIndex,
        children: pages,
      ),
      sidebar: Sidebar(
        minWidth: 220,
        bottom: Padding(
          padding: EdgeInsets.all(16.0),
          child: MacosListTile(
            onClick: () => showMacosAlertDialog(
              barrierDismissible: true,
              useRootNavigator: false,
              context: context,
              builder: (context) => MacosAlertDialog(
                appIcon: Icon(Icons.subway_sharp),
                title: Text(
                  'Mars Xlog Decoder Tool v1.0',
                ),
                message: Text(
                  'Copyright © Jerryfans 2022',
                ),
                //horizontalActions: false,
                primaryButton: PushButton(
                  buttonSize: ButtonSize.large,
                  child: const Text('确定'),
                  onPressed: Navigator.of(context).pop,
                ),
              ),
            ),
            leading: Icon(Icons.subway_sharp),
            title: Text(
                  'Xlog Decoder Tool v1.0',
                ),
            subtitle: Text('Copyright © Jerryfans'),
          ),
        ),
        builder: (context, controller) {
          return SidebarItems(
            currentIndex: pageIndex,
            onChanged: (i) => setState(() => pageIndex = i),
            scrollController: controller,
            items: [
              SidebarItem(
                leading: MacosIcon(
                    CupertinoIcons.rectangle_fill_on_rectangle_angled_fill),
                label: Text('Xlog Decode'),
              ),
            ],
          );
        },
      ),
    );
  }
}