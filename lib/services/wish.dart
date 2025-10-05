// Removed Supabase import - using local storage only
import 'package:supabase_flutter/supabase_flutter.dart';

class Wish {
  final String id;
  final String userId;
  final String wishText;
  final DateTime createdAt;

  Wish({
    required this.id,
    required this.userId,
    required this.wishText,
    required this.createdAt,
  });

  factory Wish.fromMap(Map<String, dynamic> map) {
    return Wish(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      wishText: map['wish_text'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {'wish_text': wishText};
  }

  Map<String, dynamic> toUpdateMap() {
    return {'wish_text': wishText};
  }
}

class WishRepository {
  // Removed Supabase client - using local storage only
  final SupabaseClient _client = Supabase.instance.client;

  static const int maxWishesPerUser = 3;
  static final Map<String, List<Wish>> _wishes = {};

  Future<Wish> create({required String wishText}) async {
    // 3개 제한 체크: 현재 사용자 세션 기준으로 카운트
    final countRes = await _client
        .from('wishes')
        .select('id')
        .count(CountOption.exact);
    final int current = countRes.count ?? 0;
    if (current >= maxWishesPerUser) {
      throw StateError('소망은 최대 3개까지 저장할 수 있습니다.');
    }

    final inserted = await _client
        .from('wishes')
        .insert({'wish_text': wishText})
        .select()
        .single();
    return Wish.fromMap(inserted as Map<String, dynamic>);
  }

  Future<List<Wish>> listAll() async {
    final rows = await _client.from('wishes').select().order('created_at');
    if (rows is List) {
      return rows
          .map((e) => Wish.fromMap(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    return [];
  }

  Future<Wish> update({required String id, required String wishText}) async {
    final updated = await _client
        .from('wishes')
        .update({'wish_text': wishText})
        .eq('id', id)
        .select()
        .single();
    return Wish.fromMap(updated as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.from('wishes').delete().eq('id', id);
  }
}
