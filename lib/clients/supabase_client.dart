import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClient {
  init() {
    Supabase.initialize(
      url: 'https://rxahdcgfmmmohpojvtge.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ4YWhkY2dmbW1tb2hwb2p2dGdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1OTExNDMsImV4cCI6MjA2OTE2NzE0M30.94zJ7ElfjD78d35fEhO4x9ROyH6mcA8u6qX6K5i1fAg',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
}
