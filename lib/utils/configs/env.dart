import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseApiUrl => dotenv.env['SUPABASE_API_URL'] ?? '';
  static String get supabaseApiKey => dotenv.env['SUPABASE_API_KEY'] ?? '';

  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }
}
