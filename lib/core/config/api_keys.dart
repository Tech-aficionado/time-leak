class ApiKeys {
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '965520313037-gu3hhurufs8ouqtg36lgqb376lb1h1lb.apps.googleusercontent.com',
  );

  // Supabase project credentials
  static const String supabaseUrl = 'https://tnohmepuuahjmygazkqp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRub2htZXB1dWFoam15Z2F6a3FwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyMzU5NjIsImV4cCI6MjA5MDgxMTk2Mn0.kUklIMt5IQ4Baj0Eu7xyAtfyjITHanrvCks3U9QvUdQ';
}
