class SupabaseConfig {
  // 🧪 테스트용 설정 - 실제 키로 교체 필요
  static const String supabaseUrl = 'https://rxahdcgfmmmohpojvtge.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ4YWhkY2dmbW1tb2hwb2p2dGdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1OTExNDMsImV4cCI6MjA2OTE2NzE0M30.94zJ7ElfjD78d35fEhO4x9ROyH6mcA8u6qX6K5i1fAg';

  // 개발/프로덕션 환경 구분
  static const bool isProduction = false;

  // 개발 환경 설정
  static const String devSupabaseUrl =
      'https://rxahdcgfmmmohpojvtge.supabase.co';
  static const String devSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ4YWhkY2dmbW1tb2hwb2p2dGdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1OTExNDMsImV4cCI6MjA2OTE2NzE0M30.94zJ7ElfjD78d35fEhO4x9ROyH6mcA8u6qX6K5i1fAg';

  // 프로덕션 환경 설정
  static const String prodSupabaseUrl =
      'https://rxahdcgfmmmohpojvtge.supabase.co';
  static const String prodSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ4YWhkY2dmbW1tb2hwb2p2dGdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1OTExNDMsImV4cCI6MjA2OTE2NzE0M30.94zJ7ElfjD78d35fEhO4x9ROyH6mcA8u6qX6K5i1fAg';

  static String get url => isProduction ? prodSupabaseUrl : devSupabaseUrl;
  static String get anonKey =>
      isProduction ? prodSupabaseAnonKey : devSupabaseAnonKey;
}
