
import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

Future<SupabaseClient> conectar() async {
  final env = DotEnv(includePlatformEnvironment: true)..load();

  final supabaseUrl = env['SUPABASE_URL'];
  final supabaseKey = env['SUPABASE_PUBLISHABLE_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseKey == null ||
      supabaseKey.isEmpty) {
    throw Exception(
      'Variáveis SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY '
      'não encontradas no arquivo .env.',
    );
  }

  return SupabaseClient(supabaseUrl, supabaseKey);
}
