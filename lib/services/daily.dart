import 'package:supabase_flutter/supabase_flutter.dart';

class Daily {
  final String id;
  final String userId;
  final DateTime date; // stored as DATE in DB, but we use DateTime (midnight)
  final String? goal;
  final String? gratitude;
  final String? diaryEntry;
  final DateTime createdAt;

  Daily({
    required this.id,
    required this.userId,
    required this.date,
    this.goal,
    this.gratitude,
    this.diaryEntry,
    required this.createdAt,
  });

  factory Daily.fromMap(Map<String, dynamic> map) {
    return Daily(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      goal: map['goal'] as String?,
      gratitude: map['gratitude'] as String?,
      diaryEntry: map['diary_entry'] as String?,
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
      'diary_entry': diaryEntry,
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'goal': goal,
      'gratitude': gratitude,
      'diary_entry': diaryEntry,
    }..removeWhere((key, value) => value == null);
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
    String? goal,
    String? gratitude,
    String? diaryEntry,
  }) async {
    final data = {
      'date': Daily._formatDate(date),
      if (goal != null) 'goal': goal,
      if (gratitude != null) 'gratitude': gratitude,
      if (diaryEntry != null) 'diary_entry': diaryEntry,
    };

    final inserted = await _client
        .from('dailies')
        .upsert(data, onConflict: 'user_id,date')
        .select()
        .single();
    return Daily.fromMap(inserted as Map<String, dynamic>);
  }

  Future<Daily?> getByDate(DateTime date) async {
    final rows = await _client
        .from('dailies')
        .select()
        .eq('date', Daily._formatDate(date))
        .limit(1);
    if (rows is List && rows.isNotEmpty) {
      return Daily.fromMap(rows.first as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Daily>> listRange({required DateTime start, required DateTime end}) async {
    final rows = await _client
        .from('dailies')
        .select()
        .gte('date', Daily._formatDate(start))
        .lte('date', Daily._formatDate(end))
        .order('date');
    if (rows is List) {
      return rows
          .map((e) => Daily.fromMap(e as Map<String, dynamic>))
          .toList(growable: false);
    }
    return [];
  }

  Future<Daily> updateByDate({
    required DateTime date,
    String? goal,
    String? gratitude,
    String? diaryEntry,
  }) async {
    final payload = <String, dynamic>{
      if (goal != null) 'goal': goal,
      if (gratitude != null) 'gratitude': gratitude,
      if (diaryEntry != null) 'diary_entry': diaryEntry,
    };

    final updated = await _client
        .from('dailies')
        .update(payload)
        .eq('date', Daily._formatDate(date))
        .select()
        .single();
    return Daily.fromMap(updated as Map<String, dynamic>);
  }

  Future<void> deleteByDate(DateTime date) async {
    await _client
        .from('dailies')
        .delete()
        .eq('date', Daily._formatDate(date));
  }
}


