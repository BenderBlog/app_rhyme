import 'package:app_rhyme/comp/card/music_card.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/selection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// PlayMusicList组件
class PlayMusicList extends StatelessWidget {
  const PlayMusicList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var musics = globalAudioServiceHandler.musicQueue.downCast();

      return Expanded(
          child: CustomScrollView(
        slivers: <Widget>[
          SliverList.separated(
            separatorBuilder: (context, index) => const Divider(
              color: CupertinoColors.systemGrey,
              indent: 50,
              endIndent: 50,
            ),
            itemBuilder: (context, index) => MusicCard(
              showQualityBackGround: false,
              padding: const Padding(padding: EdgeInsets.only(left: 25)),
              key: ValueKey((musics[index].info.name +
                      musics[index].info.source +
                      musics[index].info.name)
                  .hashCode),
              music: musics[index],
              onClick: () {
                globalAudioServiceHandler.skipToMusic(index);
              },
              onPress: () {
                showCupertinoPopupWithActions(context: context, options: [
                  "删除",
                  "添加"
                ], actionCallbacks: [
                  () async {
                    globalAudioServiceHandler.delMusic(index);
                  },
                  () async {
                    var tables = await globalSqlMusicFactory.readMusicLists();
                    var tableNames = tables.map((e) => e.name).toList();
                    if (context.mounted) {
                      showCupertinoPopupWithSameAction(
                          context: context,
                          options: tableNames,
                          actionCallbacks: (index_) async {
                            await globalSqlMusicFactory.insertMusic(
                                musicList: tables[index_],
                                musics: [musics[index].ref]);
                          });
                    }
                  }
                ]);
              },
            ),
            itemCount: musics.length,
          ),
        ],
      ));
    });
  }
}
