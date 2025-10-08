import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wish.dart';

class WishService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 새로운 소망을 생성합니다
  Future<Wish> createWish(String wishText) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final response = await _supabase
          .from('wishes')
          .insert({'wish_text': wishText})
          .select()
          .single();

      print('소망 생성 성공: $wishText');
      return Wish.fromMap(response);
    } catch (e) {
      print('소망 생성 실패: $e');
      rethrow;
    }
  }

  /// 사용자의 모든 소망을 조회합니다
  Future<List<Wish>> getUserWishes() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final response = await _supabase
          .from('wishes')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      final wishes = (response as List)
          .map((wish) => Wish.fromMap(wish))
          .toList();

      print('소망 조회 성공: ${wishes.length}개');
      return wishes;
    } catch (e) {
      print('소망 조회 실패: $e');
      return [];
    }
  }

  /// 소망을 수정합니다
  Future<Wish> updateWish(String wishId, String newWishText) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final response = await _supabase
          .from('wishes')
          .update({'wish_text': newWishText})
          .eq('id', wishId)
          .eq('user_id', user.id)
          .select()
          .single();

      print('소망 수정 성공: $wishId');
      return Wish.fromMap(response);
    } catch (e) {
      print('소망 수정 실패: $e');
      rethrow;
    }
  }

  /// 소망을 삭제합니다
  Future<void> deleteWish(String wishId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      await _supabase
          .from('wishes')
          .delete()
          .eq('id', wishId)
          .eq('user_id', user.id);

      print('소망 삭제 성공: $wishId');
    } catch (e) {
      print('소망 삭제 실패: $e');
      rethrow;
    }
  }

  /// 사용자의 소망 개수를 확인합니다 (최대 3개 제한)
  Future<int> getUserWishCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      final response = await _supabase
          .from('wishes')
          .select('id')
          .eq('user_id', user.id);

      return (response as List).length;
    } catch (e) {
      print('소망 개수 확인 실패: $e');
      return 0;
    }
  }

  /// 소망을 생성하거나 수정합니다 (upsert)
  Future<Wish> createOrUpdateWish(String? wishId, String wishText) async {
    if (wishId != null && wishId.isNotEmpty) {
      // 기존 소망 수정
      return await updateWish(wishId, wishText);
    } else {
      // 새 소망 생성
      return await createWish(wishText);
    }
  }
}
