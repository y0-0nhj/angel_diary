import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentMusicIndex = 0;

  final List<String> _musicPlaylist = ['audio/기다림.mp3', 'audio/꿈속에서만나.mp3'];

  Future<void> initialize() async {
    // 초기 설정
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource(_musicPlaylist[_currentMusicIndex]));
    }
    _isPlaying = !_isPlaying;
  }

  Future<void> nextSong() async {
    _currentMusicIndex = (_currentMusicIndex + 1) % _musicPlaylist.length;
    if (_isPlaying) {
      await _audioPlayer.play(AssetSource(_musicPlaylist[_currentMusicIndex]));
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
