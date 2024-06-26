import 'dart:math';

import 'package:app_rhyme/comp/music_bar/bar.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/out_music_list_grid.dart';
import 'package:app_rhyme/page/search_page.dart';
import 'package:app_rhyme/page/setting.dart';
import 'package:app_rhyme/page/user_agreement.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/pull_down_selection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pull_down_button/pull_down_button.dart';

class FloatWidgetController extends GetxController {
  final Map msgs = {};
  int index = 0;
  var isVisible = false.obs; // Observable for visibility.

  int addMsg(String msg) {
    index++;
    msgs[index] = msg;
    show();
    return index;
  }

  void delMsg(int index) {
    msgs.remove(index);
    if (msgs.isEmpty) {
      hide();
    }
  }

  void show() {
    isVisible.value = true; // Update visibility.
    update();
  }

  void hide() {
    isVisible.value = false; // Update visibility.
    update();
  }
}

class TopUiController extends GetxController {
  var currentIndex = 0.obs;
  Rx<Widget> currentWidget = Rx<Widget>(const MusicListsPage());
  Widget musicListsPageWidget = const MusicListsPage();
  Widget searchPageWidget = const SearchPage();
  void changeTabIndex(int index) {
    currentIndex.value = index;
    update();
    switch (index) {
      case 0:
        currentWidget.value = musicListsPageWidget;
        break;
      case 1:
        currentWidget.value = searchPageWidget;
        break;
      case 2:
        currentWidget.value = const SettingsPage();
        break;
      default:
        currentWidget.value = const Text("No Widget");
    }
    update();
  }

  void updateWidget(Widget widget) {
    switch (currentIndex.value) {
      case 0:
        musicListsPageWidget = widget;
        break;
      case 1:
        searchPageWidget = widget;
        break;
      default:
        currentWidget.value = widget;
    }
    changeTabIndex(currentIndex.value);
  }

  void backToOriginWidget() {
    switch (currentIndex.value) {
      case 0:
        musicListsPageWidget = const MusicListsPage();
        break;
      case 1:
        searchPageWidget = const SearchPage();
        break;
      default:
    }

    changeTabIndex(currentIndex.value);
  }
}

final TopUiController globalTopUiController = Get.put(TopUiController());

final globalFloatWidgetContoller = FloatWidgetController();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalFloatWidgetContoller.hide();
      if (!globalConfig.userAgreement) {
        showUserAgreement(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: Stack(
        children: [
          SafeArea(
            child: Obx(() {
              return globalTopUiController.currentWidget.value;
            }),
          ),

          // 使用MediaQuery检测键盘是否可见
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 用来指示是否有异步任务在进行中
                Obx(() => Visibility(
                    visible: globalFloatWidgetContoller.isVisible.value,
                    child: Row(
                      children: [
                        GestureDetector(
                          child: Container(
                              margin: const EdgeInsets.only(left: 5, bottom: 5),
                              constraints: const BoxConstraints(
                                  maxWidth: 50, maxHeight: 50),
                              decoration: BoxDecoration(
                                color: CupertinoColors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(CupertinoIcons
                                  .square_stack_3d_down_right_fill)),
                          onTapDown: (details) {
                            var position = details.globalPosition & Size.zero;
                            showPullDownMenu(
                                context: context,
                                items: floatWidgetPullDown(position),
                                position: position);
                          },
                        ),
                      ],
                    ))),
                // 音乐播放控制栏
                MusicPlayBar(
                  maxHeight: min(60, MediaQuery.of(context).size.height * 0.1),
                ),
                // 底部导航按钮
                Obx(() => CupertinoTabBar(
                      activeColor: activeIconColor,
                      backgroundColor: barBackgoundColor,
                      currentIndex: globalTopUiController.currentIndex.value,
                      onTap: globalTopUiController.changeTabIndex,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Icon(
                              CupertinoIcons.music_albums_fill,
                            ),
                          ),
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Icon(CupertinoIcons.search),
                          ),
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Icon(CupertinoIcons.settings),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
