import 'package:supabase_flutter/supabase_flutter.dart';

class Daily {
  final String id;
  final String userId;
  final DateTime date; // stored as DATE in DB, but we use DateTime (midnight)
  final Map<String, dynamic>? goal; // JSONB for checklist items
  final Map<String, dynamic>? gratitude; // JSONB for checklist items
  final String? diary; // renamed from diaryEntry to match schema
  final DateTime createdAt;

  Daily({
    required this.id,
    required this.userId,
    required this.date,
    this.goal,
    this.gratitude,
    this.diary,
    required this.createdAt,
  });

  factory Daily.fromMap(Map<String, dynamic> map) {
    return Daily(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      goal: map['goal'] as Map<String, dynamic>?,
      gratitude: map['gratitude'] as Map<String, dynamic>?,
      diary: map['diary'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      // id is default
      // user_id uses RLS default auth.uid()
      'date': _formatDate(date),
      'goal': goal,
      'gratitude': gratitude,
      'diary': diary,
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toUpdateMap() {
    return {'goal': goal, 'gratitude': gratitude, 'diary': diary}
      ..removeWhere((key, value) => value == null);
  }

  static String _formatDate(DateTime dt) {
    // yyyy-MM-dd for DATE type
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}

class DailyRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Daily> createOrUpsert({
    required DateTime date,
    Map<String, dynamic>? goal,
    Map<String, dynamic>? gratitude,
    String? diary,
  }) async {
    final data = {
      'date': Daily._formatDate(date),
      if (goal != null) 'goal': goal,
      if (gratitude != null) 'gratitude': gratitude,
      if (diary != null) 'diary': diary,
    };

    final inserted = await _client
        .from('dailies')
        .upsert(data, onConflict: 'user_id,date')
        .select()
        .single();
    return Daily.fromMap(inserted);
  }

  Future<Daily?> getByDate(DateTime date) async {
    final rows = await _client
        .from('dailies')
        .select()
        .eq('date', Daily._formatDate(date))
        .limit(1);
    if (rows.isNotEmpty) {
      return Daily.fromMap(rows.first);
    }
    return null;
  }

  Future<List<Daily>> listRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await _client
        .from('dailies')
        .select()
        .gte('date', Daily._formatDate(start))
        .lte('date', Daily._formatDate(end))
        .order('date');
    return rows
        .map((e) => Daily.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
    return [];
  }

  Future<Daily> updateByDate({
    required DateTime date,
    Map<String, dynamic>? goal,
    Map<String, dynamic>? gratitude,
    String? diary,
  }) async {
    final payload = <String, dynamic>{
      if (goal != null) 'goal': goal,
      if (gratitude != null) 'gratitude': gratitude,
      if (diary != null) 'diary': diary,
    };

    final updated = await _client
        .from('dailies')
        .update(payload)
        .eq('date', Daily._formatDate(date))
        .select()
        .single();
    return Daily.fromMap(updated);
  }

  Future<void> deleteByDate(DateTime date) async {
    await _client.from('dailies').delete().eq('date', Daily._formatDate(date));
  }
}
