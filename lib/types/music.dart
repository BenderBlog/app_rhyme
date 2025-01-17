import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/src/rust/api/music_sdk.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:audio_service/audio_service.dart';

// 是一个原本只具有展示功能的DisplayMusicTuple通过请求第三方api变成可以播放的音乐
// 这个过程已经决定了一个音乐是否可以播放，因此本函数应该可能throw Exception
Future<PlayMusic> display2PlayMusic(DisplayMusic music) async {
  late Quality defaultQuality;
  if (music.info.defaultQuality != null) {
    defaultQuality = music.info.defaultQuality!;
  } else if (music.info.qualities.isNotEmpty) {
    defaultQuality = music.info.qualities[0];
    log("音乐无默认音质,选择音质中第一个进行播放:$defaultQuality");
  } else {
    throw Exception("音乐无可播放音质");
  }
  // 音乐缓存获取的逻辑
  var extra = music.ref.getExtraInto(quality: defaultQuality);
  if (globalExternApi == null) {
    log("无第三方音乐源,无法获取播放信息");
    throw Exception("无第三方音乐源,无法获取播放信息");
  }
  var playinfo =
      await globalExternApi!.getMusicPlayInfo(music.info.source, extra);

  var playMusic = PlayMusic(music.ref, music.info, playinfo, extra);

  String? file = await useCacheFile(
      file: "",
      cachePath: musicCachePath,
      filename: playMusic.toCacheFileName());
  if (file != null) {
    playMusic.playInfo.file = file;
    playMusic.hasCache = true;
    log("使用缓存后音乐进行播放: $file");
  }

  return playMusic;
}

void log(String s) {}

class DisplayMusic {
  late MusicW ref;
  late MusicInfo info;
  DisplayMusic(MusicW musicRef_) {
    ref = musicRef_;
    info = ref.getMusicInfo();
  }
  String toCacheFileName() {
    if (info.defaultQuality == null) {
      return "";
    }
    return "${info.name}_${info.artist.join(',')}_${info.source}_${ref.getExtraInto(quality: info.defaultQuality!).hashCode}.${info.defaultQuality!.format ?? "unknown"}";
  }

  Future<bool> hasCache() async {
    var cache = await useCacheFile(
        file: "", cachePath: musicCachePath, filename: toCacheFileName());
    if (cache != null) {
      return true;
    } else {
      return false;
    }
  }
}

class PlayInfo {
  late String file;
  late Quality quality;
  PlayInfo(
    String file_,
    Quality quality_,
  ) {
    file = file_;
    quality = quality_;
  }
  factory PlayInfo.fromObject(dynamic obj) {
    return PlayInfo(
      obj['url'],
      Quality.fromObject(obj['quality']),
    );
  }
}

// 这个结构代表了待播音乐的信息
class PlayMusic {
  late MusicW ref;
  late MusicInfo info;
  late MediaItem item;
  late PlayInfo playInfo;
  late String extra;
  bool hasCache = false;
  PlayMusic(
      MusicW musicRef_, MusicInfo info_, PlayInfo playinfo_, String extra_) {
    ref = musicRef_;
    info = info_;
    playInfo = playinfo_;
    extra = extra_;
    item = MediaItem(
        id: info.name + info.source + info.artist.join(","),
        title: info.name,
        album: info.album,
        artUri: () {
          if (info.artPic != null) {
            return Uri.parse(info.artPic!);
          } else {
            return null;
          }
        }(),
        displayTitle: info.name,
        displaySubtitle: info.artist.join(","));
  }
  String toCacheFileName() {
    return "${info.name}_${info.artist.join(',')}_${info.source}_${extra.hashCode}.${playInfo.quality.format ?? "unknown"}";
  }
}
