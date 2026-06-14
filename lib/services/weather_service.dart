import "dart:convert";
import "package:http/http.dart" as http;

class WeatherService {
  static Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url = Uri.parse("https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code,is_day&daily=temperature_2m_max,temperature_2m_min,weather_code&timezone=auto");
    final res = await http.get(url);
    return jsonDecode(res.body);
  }

  static String weatherEmoji(int code, int isDay) {
    switch (code) {
      case 0: return isDay == 1 ? "\u2600\uFE0F" : "\uD83C\uDF19";
      case 1: case 2: case 3: return "\u26C5";
      case 45: case 48: return "\uD83C\uDF2B\uFE0F";
      case 51: case 53: case 55: return "\uD83C\uDF26\uFE0F";
      case 61: case 63: case 65: return "\uD83C\uDF27\uFE0F";
      case 71: case 73: case 75: return "\uD83C\uDF28\uFE0F";
      case 80: case 81: case 82: return "\uD83C\uDF26\uFE0F";
      case 95: case 96: case 99: return "\u26C8\uFE0F";
      default: return "\u2600\uFE0F";
    }
  }
}
