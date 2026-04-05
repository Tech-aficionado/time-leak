import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/config/api_keys.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: ApiKeys.geminiApiKey,
    );
  }

  Future<String> generateUsageReport(String prompt) async {
    if (ApiKeys.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || ApiKeys.geminiApiKey.isEmpty) {
      return 'AI ANALYSIS OFFLINE: Please provide a valid Gemini API Key in the system configuration to enable Neural Insights.';
    }

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'System was unable to decode neural patterns. Please try again.';
    } catch (e) {
      debugPrint('Gemini Error: $e');
      return 'Neural link interrupted. Error: ${e.toString()}';
    }
  }
}
