// 단순 BGM 재생을 위한 경량 오디오 서비스입니다.
// - 상태: 재생 여부, 현재 곡 인덱스
// - 동작: 토글 재생/일시정지, 다음 곡으로 이동 (재생 중이면 즉시 재생)
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentMusicIndex = 0;

  final List<String> _musicPlaylist = ['audio/기다림.mp3', 'audio/꿈속에서만나.mp3'];

  /// 필요 시 플레이어 설정/프리로딩 등 초기 준비를 수행합니다.
  Future<void> initialize() async {
    // 초기 설정(옵션): 캐시/음량/루프 등의 설정 지점을 확보합니다.
  }

  /// 재생/일시정지를 토글합니다. 비동기 재생 후 내부 상태를 갱신합니다.
  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource(_musicPlaylist[_currentMusicIndex]));
    }
    _isPlaying = !_isPlaying;
  }

  /// 다음 곡으로 인덱스를 순환시키고, 재생 중이라면 즉시 해당 곡을 재생합니다.
  Future<void> nextSong() async {
    _currentMusicIndex = (_currentMusicIndex + 1) % _musicPlaylist.length;
    if (_isPlaying) {
      await _audioPlayer.play(AssetSource(_musicPlaylist[_currentMusicIndex]));
    }
  }

  /// 리소스 정리.
  void dispose() {
    _audioPlayer.dispose();
  }
}
