import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// 음악 재생을 관리하는 Provider
///
/// 음악 재생, 일시정지, 다음 곡 재생을 담당하고
/// UI에 음악 상태 변화를 알려줍니다.
class MusicProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentMusicIndex = 0;
  final List<String> _musicPlaylist = ['audio/기다림.mp3', 'audio/꿈속에서만나.mp3'];

  /// 현재 재생 상태
  bool get isPlaying => _isPlaying;

  /// 현재 음악 인덱스
  int get currentMusicIndex => _currentMusicIndex;

  /// 현재 재생 중인 곡
  String get currentSong => _musicPlaylist[_currentMusicIndex];

  /// 재생목록
  List<String> get playlist => List.unmodifiable(_musicPlaylist);

  MusicProvider() {
    _configureAudioPlayer();
  }

  /// 오디오 플레이어 설정
  void _configureAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((_) {
      _playNextMusic();
    });
  }

  /// 재생/일시정지 토글
  Future<void> toggleMusic() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    } else {
      await _playCurrentMusic();
      _isPlaying = true;
    }
    notifyListeners();
  }

  /// 현재 곡 재생
  Future<void> _playCurrentMusic() async {
    try {
      await _audioPlayer.play(AssetSource(_musicPlaylist[_currentMusicIndex]));
    } catch (e) {
      print('음악 재생 실패: $e');
    }
  }

  /// 다음 곡으로 이동
  Future<void> _playNextMusic() async {
    _currentMusicIndex = (_currentMusicIndex + 1) % _musicPlaylist.length;

    if (_isPlaying) {
      await _playCurrentMusic();
    }

    notifyListeners();
  }

  /// 다음 곡 재생 (수동)
  Future<void> playNext() async {
    await _playNextMusic();
  }

  /// 이전 곡으로 이동
  Future<void> playPrevious() async {
    _currentMusicIndex =
        (_currentMusicIndex - 1 + _musicPlaylist.length) %
        _musicPlaylist.length;

    if (_isPlaying) {
      await _playCurrentMusic();
    }

    notifyListeners();
  }

  /// 특정 곡으로 이동
  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _musicPlaylist.length) {
      _currentMusicIndex = index;

      if (_isPlaying) {
        await _playCurrentMusic();
      }

      notifyListeners();
    }
  }

  /// 음악 정지
  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    notifyListeners();
  }

  /// 리소스 정리
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
