import 'package:app_rhyme/comp/card/playing_music_card.dart';
import 'package:app_rhyme/comp/play_page_comp/botton_button.dart';
import 'package:app_rhyme/comp/play_page_comp/control_button.dart';
import 'package:app_rhyme/comp/play_page_comp/lyric.dart';
import 'package:app_rhyme/comp/play_page_comp/music_artpic.dart';
import 'package:app_rhyme/comp/play_page_comp/music_info.dart';
import 'package:app_rhyme/comp/play_page_comp/music_list.dart';
import 'package:app_rhyme/comp/play_page_comp/progress_slider.dart';
import 'package:app_rhyme/comp/play_page_comp/quality_time.dart';
import 'package:app_rhyme/comp/play_page_comp/volume_slider.dart';
import 'package:flutter/cupertino.dart';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:pro_animated_blur/pro_animated_blur.dart';

enum PageState { main, list, lyric }

class SongDisplayPage extends StatefulWidget {
  const SongDisplayPage({super.key});

  @override
  SongDisplayPageState createState() => SongDisplayPageState();
}

class SongDisplayPageState extends State<SongDisplayPage> {
  PageState pageState = PageState.main;
  int topFlex = 5;
  int bottomFlex = 3;
  void onListBotton() {
    setState(() {
      if (pageState == PageState.list) {
        pageState = PageState.main;
        bottomFlex = 3;
      } else {
        pageState = PageState.list;
        bottomFlex = 2;
      }
    });
  }

  void onLyricBotton() {
    setState(() {
      if (pageState == PageState.lyric) {
        pageState = PageState.main;
        bottomFlex = 3;
      } else {
        pageState = PageState.lyric;
        bottomFlex = 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<Widget> topWidgets;
    switch (pageState) {
      case PageState.main:
        topWidgets = <Widget>[
          Padding(padding: EdgeInsets.only(top: screenHeight * 0.06)),
          MusicArtPic(
            imageSize: screenWidth * 0.9,
          ),
        ];
        break;
      case PageState.list:
        topWidgets = <Widget>[
          Padding(padding: EdgeInsets.only(top: screenHeight * 0.03)),
          const PlayingMusicCard(),
          const Padding(padding: EdgeInsets.only(left: 30)),
          Container(
            padding: const EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: const Text(
              '待播清单',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const PlayMusicList(),
        ];
        break;
      case PageState.lyric:
        topWidgets = [
          Padding(padding: EdgeInsets.only(top: screenHeight * 0.03)),
          const PlayingMusicCard(),
          const Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
          LyricDisplay(maxHeight: screenHeight * 0.55),
        ];
        break;
    }
    // 底部组件，包括 ProgressSlider, QualityTime, ControlButton, VolumeSlider 和 BottomButton
    List<Widget> bottomWidgets = [
      if (pageState == PageState.main) const MusicInfo(),
      const ProgressSlider(),
      const QualityTime(),
      const Padding(padding: EdgeInsets.only(top: 40)),
      ControlButton(
        buttonSize: screenWidth * 0.1,
        buttonSpacing: screenWidth * 0.2,
      ),
      const Padding(padding: EdgeInsets.only(top: 40)),
      const VolumeSlider(),
      BottomButton(
        onList: onListBotton,
        onLyric: onLyricBotton,
      ),
      const Padding(padding: EdgeInsets.only(top: 5, bottom: 5)),
    ];

    return DismissiblePage(
      isFullScreen: true,
      direction: DismissiblePageDismissDirection.down,
      backgroundColor: CupertinoColors.white,
      onDismissed: () => Navigator.of(context).pop(),
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              CupertinoColors.systemGrey2,
              CupertinoColors.systemGrey,
            ],
          ),
        ),
        child: ProAnimatedBlur(
          blur: 500,
          duration: const Duration(milliseconds: 0),
          child: Column(
            children: <Widget>[
              Flexible(
                  flex: topFlex,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: topWidgets,
                  )),
              // 使用 Expanded 包裹一个新的 Column，以便底部组件从下往上排布
              Flexible(
                flex: bottomFlex,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: bottomWidgets,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void navigateToSongDisplayPage(BuildContext context) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const SongDisplayPage(),
      fullscreenDialog: true,
    ),
  );
}
