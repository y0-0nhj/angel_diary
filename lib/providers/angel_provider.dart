import 'package:flutter/material.dart';
import '../models/angel_data.dart';
import '../managers/angel_data_manager.dart';

/// 천사 데이터를 관리하는 Provider
///
/// 천사 데이터의 로드, 저장, 삭제를 담당하고
/// UI에 상태 변화를 알려줍니다.
class AngelProvider extends ChangeNotifier {
  AngelData? _currentAngel;
  bool _isLoading = false;
  String? _error;

  /// 현재 천사 데이터
  AngelData? get currentAngel => _currentAngel;

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 에러 메시지
  String? get error => _error;

  /// 천사가 있는지 여부
  bool get hasAngel => _currentAngel != null;

  /// 천사 데이터 로드
  Future<void> loadAngel() async {
    _setLoading(true);
    _clearError();

    try {
      final angel = await AngelDataManager.loadAngelFromStorage();
      _currentAngel = angel;
      print('천사 데이터 로드 완료: ${angel?.name ?? "없음"}');
    } catch (e) {
      _setError('천사 데이터 로드 실패: $e');
      print('천사 데이터 로드 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 천사 데이터 설정 및 저장
  Future<void> setAngel(AngelData angel) async {
    _setLoading(true);
    _clearError();

    try {
      await AngelDataManager.setCurrentAngel(angel);
      _currentAngel = angel;
      print('천사 데이터 저장 완료: ${angel.name}');
    } catch (e) {
      _setError('천사 데이터 저장 실패: $e');
      print('천사 데이터 저장 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 천사 데이터 삭제
  Future<void> clearAngel() async {
    _setLoading(true);
    _clearError();

    try {
      await AngelDataManager.clearAngelData();
      _currentAngel = null;
      print('천사 데이터 삭제 완료');
    } catch (e) {
      _setError('천사 데이터 삭제 실패: $e');
      print('천사 데이터 삭제 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 천사 감정 업데이트
  void updateEmotion(int emotionIndex) {
    if (_currentAngel != null) {
      final updatedAngel = AngelData(
        name: _currentAngel!.name,
        feature: _currentAngel!.feature,
        animalType: _currentAngel!.animalType,
        faceType: _currentAngel!.faceType,
        faceColor: _currentAngel!.faceColor,
        bodyIndex: _currentAngel!.bodyIndex,
        emotionIndex: emotionIndex,
        tailIndex: _currentAngel!.tailIndex,
        createdAt: _currentAngel!.createdAt,
      );

      _currentAngel = updatedAngel;
      // 감정 변경은 자주 일어나므로 저장하지 않고 메모리에만 유지
      notifyListeners();
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 설정
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// 에러 초기화
  void _clearError() {
    _error = null;
  }
}
